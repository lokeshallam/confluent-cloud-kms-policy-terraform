# confluent-cloud-kms-policy-terraform


Terraform to generate a KMS key with appropriate policy required. 

The KMS key generated can be used as encryption_key arguement for the [Resource confluent_kafka_cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster)


## Usage 

Export variables 

TF_CONFLUENT_CLOUD_API_KEY - Confluent cloud API key with access to cloud resource
TF_CONFLUENT_CLOUD_API_SECRET

AWS KMS key variables 

alias - Display name for the key
description - Description for the key 

