#######################################################################
#internal gateway
#######################################################################
resource "aws_lb" "internal_gateway" {
  name               = "${var.service_name}-${var.env}-internal-gateway"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.internal_gateway_security_groups
  subnets            = var.private_subnet_ids

  enable_deletion_protection = true
  drop_invalid_header_fields = true

  idle_timeout = var.alb_internal_gateway_idle_time // 1 ~ 4000

  access_logs {
    bucket  = var.alb_wanrun_access_log_bucket_id
    prefix  = var.alb_wanrun_access_log_prefix
    enabled = var.env == "prod" ? true : false // 本番だけ
  }
}

resource "aws_lb_listener" "internal_gateway" {
  load_balancer_arn = aws_lb.internal_gateway.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = 404
      content_type = "text/plain"
      message_body = "Not found"
    }
  }

  depends_on = [aws_lb.internal_gateway]
}
