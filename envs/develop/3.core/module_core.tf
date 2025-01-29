module "core" {
  source = "../../../modules/core"

  service_name = var.service_name
  env          = var.env
  #   main_domain = var.web_front_domain
  # main_waf_acl_id = 
  # cloudfront_acm_arn = 
  certificate_arn = ""

  # alb
  internal_gateway_security_groups = [data.aws_security_group.internal_gateway_alb_sg.id]
  private_subnet_ids               = data.aws_subnets.private.ids
  alb_internal_gateway_idle_time   = 60

  // 本番のみ設定をする
  # alb_wanrun_access_log_bucket_id = ""
  # alb_wanrun_access_log_prefix    = ""

  # ecs cluster
  is_container_insights                          = false
  fargate_base_capacity_provider_strategy        = var.fargate_base_capacity_provider_strategy
  fargate_weight_capacity_provider_strategy      = var.fargate_weight_capacity_provider_strategy
  fargate_spot_base_capacity_provider_strategy   = var.fargate_spot_base_capacity_provider_strategy
  fargate_spot_weight_capacity_provider_strategy = var.fargate_spot_weight_capacity_provider_strategy

  # cms
  retention_period = 365

  # ecr
  ecr_namespace         = "${var.service_name}-${var.env}-wanrun"
  retention_image_count = 3

  # gateway
  cloudfront_access_control_header_key   = "X-Origin-Access-Control"
  cloudfront_access_control_header_value = data.aws_ssm_parameter.cloudfront_access_control_header_value.value
  whitelist_locations                    = ["JP"]                 // 許可する国指定
  access_control_allow_origins           = ["https://wanrun.com"] // TODO: 購入したドメイン名
}
