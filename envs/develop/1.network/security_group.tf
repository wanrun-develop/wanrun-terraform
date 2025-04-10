###########################################
# VPC Endpoint
###########################################
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.service_name}-${var.env}-vpc-endpoint"
  vpc_id      = aws_vpc.main.id
  description = "vpc-endpoint"
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint_egress" {
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  description = "Allow all"

  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    Name = "${var.service_name}-${var.env}-vpc-endpoint-egress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_ingress" {
  ip_protocol = "-1"
  cidr_ipv4   = var.vpc_cidr
  description = "Allow this vpc"

  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    Name = "${var.service_name}-${var.env}-vpc-endpoint-ingress"
  }
}

#######################################################################
# Postgres on EC2
#######################################################################
resource "aws_security_group" "postgres_on_ec2" {
  name   = "${var.service_name}-${var.env}-postgres-on-ec2-sg"
  vpc_id = aws_vpc.main.id

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
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#######################################################################
# lambda ssr
#######################################################################
resource "aws_security_group" "lambda_ssr" {
  name   = "${var.service_name}-${var.env}-lambda-ssr-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-${var.env}-lambda-ssr-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lambda_ssr" {
  security_group_id = aws_security_group.lambda_ssr.id
  description       = "Allow all vpc"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "lambda_ssr" {
  security_group_id = aws_security_group.lambda_ssr.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#######################################################################
# Fargate
#######################################################################
resource "aws_security_group" "fargate" {
  name   = "${var.service_name}-${var.env}-fargate-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-${var.env}-fargate-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fargate" {
  ip_protocol = "-1"
  cidr_ipv4   = var.vpc_cidr
  description = "Allow this vpc"

  security_group_id = aws_security_group.fargate.id

  tags = {
    Name = "${var.service_name}-${var.env}-fargate-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "fargate" {
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  description = "Allow all"

  security_group_id = aws_security_group.fargate.id

  tags = {
    Name = "${var.service_name}-${var.env}-fargate-egress"
  }
}
