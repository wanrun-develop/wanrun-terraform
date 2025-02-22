resource "aws_eip" "ntgw" {
  domain = "vpc"

  tags = {
    "Name" = "${var.service_name}-${var.env}-nat-gateway-ip"
  }

  depends_on = [ aws_internet_gateway.main ]
}
