data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "service_name" {
  type    = string
  default = "wr"
}
