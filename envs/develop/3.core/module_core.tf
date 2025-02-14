module "core" {
  source = "../../../modules/core"

  providers = {
    aws.virginia = aws.virginia
  }
  service_name       = var.service_name
  env                = var.env
  main_domain        = data.aws_acm_certificate.wanrun_jp.domain
  cloudfront_acm_arn = data.aws_acm_certificate.wanrun_jp.arn
  # main_waf_acl_id =  // NOTE: WAFを使う場合

  # alb
  internal_gateway_security_groups = [data.aws_security_group.internal_gateway_alb_sg.id]
  vpc_id                           = data.aws_vpc.wanrun.id
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
  whitelist_locations          = ["JP"] // NOTE: 許可する国指定
  access_control_allow_origins = ["https://wanrun.jp"]
}
