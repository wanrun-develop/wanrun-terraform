resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.ntgw.id
  // develop環境だからntgwが1つ
  subnet_id = aws_subnet.public_subnets[element(keys(aws_subnet.public_subnets), 0)].id

  tags = {
    Name = "${var.service_name}-${var.env}-main-ntgw"
  }
  depends_on = [aws_internet_gateway.igw]
}
