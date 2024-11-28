locals {
  # kms
  kms_alias_name = "alias/global-${var.service_name}"
}

###########################################
# data参照
###########################################
data "aws_kms_key" "wanrun" {
  key_id = local.kms_alias_name
}
