module "core" {
  source = "../../../modules/ops"

  service_name     = var.service_name
  env              = var.env
  retention_period = 365

  ssm_parameter_store_prefix = local.ssm_parameter_store_prefix
  kms_key_arn                = data.aws_kms_key.wanrun.arn
}
