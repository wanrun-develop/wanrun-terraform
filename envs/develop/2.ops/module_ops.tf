module "core" {
  source = "../../../modules/ops"

  service_name     = var.service_name
  env              = var.env
  retention_period = 365
}
