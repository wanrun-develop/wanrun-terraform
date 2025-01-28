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

#######################################################################
# ALB
#######################################################################
resource "aws_security_group" "internal_gateway" {
  name        = "${var.service_name}-${var.env}-internal-gateway-alb-sg"
  vpc_id      = aws_vpc.wanrun.id
  description = "${var.service_name}-${var.env}-internal-gateway-alb-sg"

  tags = {
    Name = "${var.service_name}-${var.env}-internal-gateway-alb-sg"
  }
}

// TODO: vpc origin生成後、こちらは削除する
resource "aws_vpc_security_group_ingress_rule" "cloudfront_managed_prefix_list" {
  security_group_id = aws_security_group.internal_gateway.id
  description       = "Allow CloudFront IPs"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id // AWSが提供しているcloudfrontのプレフィックスリスト
}

resource "aws_vpc_security_group_egress_rule" "internal_gateway" {
  security_group_id = aws_security_group.internal_gateway.id
  from_port         = "0"
  ip_protocol       = "-1"
  to_port           = "0"
  cidr_ipv4         = "0.0.0.0/0"
}

// TODO: vpc originが生成されたから付け替える。現状一括でできるAPIがないため
# data "aws_security_group" "vpc_origin_sg" {
#   name = "CloudFront-VPCOrigins-Service-SG"
# }
# resource "aws_vpc_security_group_ingress_rule" "vpc_origin" {
#   security_group_id            = aws_security_group.internal_gateway.id
#   from_port                    = 80
#   ip_protocol                  = "tcp"
#   to_port                      = 80
#   referenced_security_group_id = data.aws_security_group.vpc_origin_sg.id
# }

#######################################################################
# Postgres on EC2
#######################################################################
resource "aws_security_group" "postgres_on_ec2" {
  name   = "${var.service_name}-${var.env}-postgres-on-ec2-sg"
  vpc_id = aws_vpc.wanrun.id

  tags = {
    Name = "${var.service_name}-${var.env}-postgres-on-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_on_ec2" {
  security_group_id = aws_security_group.postgres_on_ec2.id
  description       = "Allow all vpc"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "postgres_on_ec2" {
  security_group_id = aws_security_group.postgres_on_ec2.id
  from_port         = "0"
  ip_protocol       = "-1"
  to_port           = "0"
  cidr_ipv4         = "0.0.0.0/0"
}
