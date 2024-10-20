resource "aws_lb" "wanrun_be" {
  name               = "${var.service_name}-${var.env}-wanrun"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_wanrun_sgs]
  subnets            = var.public_subnets

  enable_deletion_protection = true
  drop_invalid_header_fields = true

  idle_timeout = var.alb_wanrun_idle_time # 1 ~ 4000

  access_logs {
    bucket  = var.alb_wanrun_access_log_bucket_id
    prefix  = var.alb_wanrun_access_log_prefix
    enabled = var.env == "prod" ? true : false
  }
}

resource "aws_lb_listener" "wanrun_be" {
  load_balancer_arn = aws_lb.wanrun_be.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy // defalult: ELBSecurityPolicy-2016-08. ELBSecurityPolicy-TLS-1-2-2017-01, ELBSecurityPolicy-TLS-1-3-2021-06

  certificate_arn = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = 404
      content_type = "text/plain"
      message_body = "Not found"
    }
  }
}
