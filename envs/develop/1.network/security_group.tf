###########################################
# VPC Endpoint
###########################################
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.service_name}-${var.env}-vpc-endpoint"
  vpc_id      = aws_vpc.wanrun.id
  description = "vpc-endpoint"

  ingress {
    cidr_blocks = [var.vpc_cidr]
    description = "Allow this VPC"
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint_egress" {
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = "0"
  to_port = "0"
  description = "Allow all"

  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    Name = "${var.service_name}-${var.env}-vpc-endpoint-egress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_ingress" {
  ip_protocol = "-1"
  cidr_ipv4 = var.vpc_cidr
  from_port = "0"
  to_port = "0"
  description = "Allow this vpc"

  security_group_id = aws_security_group.vpc_endpoint.id

  tags = {
    Name = "${var.service_name}-${var.env}-vpc-endpoint-ingress"
  }
}
