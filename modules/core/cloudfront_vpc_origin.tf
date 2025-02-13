#######################################################################
# cloudfront vpc origin
#######################################################################
resource "aws_cloudfront_vpc_origin" "main_internal_alb" {
  vpc_origin_endpoint_config {
    name                   = "${var.service_name}-${var.env}-main-internal-alb"
    arn                    = aws_lb.internal_gateway.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "https-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
  tags = {
    "Name" = "${var.service_name}-${var.env}-main-internal-alb"
  }
  depends_on = [aws_lb.internal_gateway]
}
