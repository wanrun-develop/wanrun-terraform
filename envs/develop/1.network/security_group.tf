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
