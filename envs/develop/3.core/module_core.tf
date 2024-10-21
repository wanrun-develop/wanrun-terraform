module "core" {
  source = "../../../modules/core"

  service_name = var.service_name
  env          = var.env
  #   web_front_domain = var.web_front_domain
  # front_web_waf_acl_id = 
  # cloudfront_acm_arn = 

  alb_wanrun_sgs       = [data.aws_security_group.alb_sg.id]
  public_subnets       = data.aws_subnets.public.ids
  alb_wanrun_idle_time = 60
  certificate_arn      = ""

  // 本番だけ
  alb_wanrun_access_log_bucket_id = ""
  alb_wanrun_access_log_prefix    = ""
}
