variable "CONFLUENT_CLOUD_API_KEY" {
  type = string
}

variable "CONFLUENT_CLOUD_API_SECRET" {
  type = string
}

variable "description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

variable "key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}

variable "rotation_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the key."
}

variable "alias" {
  type        = string
  description = "The display name of the key."
}

variable "policy" {
  type        = string
  description = "A valid policy JSON document. This is a key policy, not an IAM policy."
}