
#######################################################################
# route53
#######################################################################
resource "aws_route53_zone" "wanrun" {
  name = "wanrun.jp"
}

resource "aws_route53_record" "wanrun" {
  zone_id = aws_route53_zone.wanrun.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = module.core.cloudfront_domain_name
    zone_id                = module.core.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
