module "core" {
  source = "../../../modules/core"

  service_name = var.service_name
  env          = var.env
  #   main_domain = var.web_front_domain
  # main_waf_acl_id = 
  # cloudfront_acm_arn = 

  alb_wanrun_sgs       = [data.aws_security_group.alb_sg.id]
  public_subnets       = data.aws_subnets.public.ids
  alb_wanrun_idle_time = 60
  certificate_arn      = ""

  // 本番のみ設定をする
  alb_wanrun_access_log_bucket_id = ""
  alb_wanrun_access_log_prefix    = ""

  // ecs cluster
  is_container_insights                          = false
  fargate_base_capacity_provider_strategy        = var.fargate_base_capacity_provider_strategy
  fargate_weight_capacity_provider_strategy      = var.fargate_weight_capacity_provider_strategy
  fargate_spot_base_capacity_provider_strategy   = var.fargate_spot_base_capacity_provider_strategy
  fargate_spot_weight_capacity_provider_strategy = var.fargate_spot_weight_capacity_provider_strategy

  # cms
  retention_period = 365

  # ecr
  retention_image_count = 3

  # gateway
  cloudfront_access_control_header_key   = "X-Origin-Access-Control"
  cloudfront_access_control_header_value = data.aws_ssm_parameter.cloudfront_access_control_header_value.value
}
