#######################################################################
# route53 public host zone
#######################################################################
resource "aws_route53_zone" "wanrun" {
  name = "wanrun.jp"
  tags = {
    Name = "wanrun.jp"
  }
}

#######################################################################
# route53 acm domain verification
#######################################################################
resource "aws_route53_record" "wanrun_dns_verify" {
  for_each = {
    for dvo in aws_acm_certificate.wanrun.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.wanrun.id
}

resource "aws_acm_certificate_validation" "public" {
  certificate_arn         = aws_acm_certificate.wanrun.arn
  validation_record_fqdns = [for record in aws_route53_record.wanrun_dns_verify : record.fqdn]
}
