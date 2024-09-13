module "web_base" {
  source = "../../../modules/web_base"

  service_name = var.service_name
  env = var.env
#   web_front_domain = var.web_front_domain
# front_web_waf_acl_id = 
# cloudfront_acm_arn = 
}
