
#######################################################################
# route53 record
#######################################################################
resource "aws_route53_record" "wanrun" {
  zone_id = data.aws_route53_zone.wanrun_jp.id
  name    = "" // NOTE: ネイキッドドメインの指定
  type    = "A"

  alias {
    name                   = module.core.cloudfront_domain_name
    zone_id                = module.core.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
