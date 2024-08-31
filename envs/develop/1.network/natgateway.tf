resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.ntgw.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "${var.service_name}-${var.env}-main-ntgw"
  }
  depends_on = [aws_internet_gateway.igw]
}
