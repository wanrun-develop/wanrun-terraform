resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wanrun.id

  tags = {
    "Name" = "${var.service_name}-${var.env}-igw"
  }

  depends_on = [aws_vpc.wanrun]
}
