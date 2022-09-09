terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0"
    }
  }
}


locals {
   
  basic_auth = format("%s%s","Basic ",base64encode(format("%s:%s",var.CONFLUENT_CLOUD_API_KEY,var.CONFLUENT_CLOUD_API_SECRET)))
}



data "http" "example" {
  
  url = "https://confluent.cloud/api/env_metadata"
  method = "GET"

  # Optional request headers
  request_headers = {
    Accept = "application/json",
    Authorization = local.basic_auth
  }
}

locals  {
  jsonoutput = jsondecode(data.http.example.response_body)
  cloudlist = local.jsonoutput.clouds
  aws_accounts = flatten([for each in local.jsonoutput.clouds : each.accounts if each.id == "aws"])
  aws_accounts_list = toset(local.aws_accounts)

  aws_accounts_final = [for k, accountid in local.aws_accounts_list : format("%s%s%s","arn:aws:iam::",accountid.id,":root")]

   
}

provider "aws" {
  region = "us-east-2"
  

}

data "aws_caller_identity" "current" {
}



data "aws_iam_policy_document" "cmk_key_policy" {
  statement {
    sid = "1"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    sid = "Allow Confluent account  to use the key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = local.aws_accounts_final
    }
    actions = [
      "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"
    ]
    resources = [
      "*",
    ]
    
  }
   statement {
    sid = "Allow Confluent account  to attach persistent resources"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = local.aws_accounts_final
    }
    actions = [
      "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"
    ]
    resources = [
      "*",
    ]
    
  }
}

resource "aws_kms_key" "cluster_key" {
  description              = var.description
  customer_master_key_spec = var.key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  tags                     = var.tags
  policy                   = data.aws_iam_policy_document.cmk_key_policy.json
  deletion_window_in_days  = 30
}

# Add an alias to the key
resource "aws_kms_alias" "cluster_key_alias" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.cluster_key.key_id
}
   