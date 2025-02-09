#######################################################################
# acm
#######################################################################
resource "aws_acm_certificate" "wanrun" {
  domain_name               = aws_route53_zone.wanrun.name
  subject_alternative_names = ["*.${aws_route53_zone.wanrun.name}"]
  validation_method         = "DNS"

  tags = {
    Name = "${var.service_name}-wanrun-jp"
  }

  lifecycle {
    create_before_destroy = true
  }
}
