variable "service_name" {
  type    = string
  default = ""
}

variable "env" {
  type    = string
  default = ""
}

variable "retention_period" {
  type    = number
  default = 365
}

variable "ssm_parameter_store_prefix" {
  type    = string
  default = ""
}

variable "kms_key_arn" {
  type    = string
  default = ""
}
