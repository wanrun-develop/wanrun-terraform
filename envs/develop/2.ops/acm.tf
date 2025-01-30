#######################################################################
# acm
#######################################################################
resource "aws_acm_certificate" "wanrun" {
  domain_name       = "*.wanrun.jp"
  validation_method = "DNS"

  tags = {
    Name = "${var.service_name}-${var.env}-wanrun"
  }

  lifecycle {
    create_before_destroy = true
  }
}
