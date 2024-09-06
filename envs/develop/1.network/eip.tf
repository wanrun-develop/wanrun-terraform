resource "aws_eip" "ntgw" {
  domain = "vpc"

  tags = {
    "Name" = "${var.service_name}-${var.env}-nat-gateway-ip"
  }
}
