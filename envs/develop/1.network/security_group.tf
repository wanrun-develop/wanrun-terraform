###########################################
# VPC Endpoint
###########################################
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.service_name}-${var.env}-vpc-endpoint"
  vpc_id      = aws_vpc.wanrun.id
  description = "vpc-endpoint"
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint_egress" {
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = "0"
  to_port     = "0"
  description = "Allow all"

  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    Name = "${var.service_name}-${var.env}-vpc-endpoint-egress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_ingress" {
  ip_protocol = "-1"
  cidr_ipv4   = var.vpc_cidr
  from_port   = "0"
  to_port     = "0"
  description = "Allow this vpc"

  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    Name = "${var.service_name}-${var.env}-vpc-endpoint-ingress"
  }
}

###########################################
# ALB
###########################################
resource "aws_security_group" "wanrun_be" {
  name        = "${var.service_name}-${var.env}-wanrun-alb-sg"
  vpc_id      = aws_vpc.wanrun.id
  description = "${var.service_name}-${var.env}-wanrun-alb-sg"

  ingress {
    prefix_list_ids = ["pl-58a04531"] // AWSが提供しているcloudfrontのプレフィックスリスト
    description     = "Allow CloudFront IPs"
    from_port       = "443"
    protocol        = "tcp"
    to_port         = "443"
  }

  ingress {
    cidr_blocks = [var.vpc_cidr]
    description = "Allow VPC in wanrun"
    from_port   = "443"
    protocol    = "tcp"
    to_port     = "443"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  tags = {
    Name = "${var.service_name}-${var.env}-wanrun-alb-sg"
  }
}
