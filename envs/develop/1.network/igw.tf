#######################################################################
# igw
#######################################################################
resource "aws_internet_gateway" "main" {
  tags = {
    "Name" = "${var.service_name}-${var.env}-igw"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_internet_gateway_attachment" "main" {
  vpc_id              = aws_vpc.main.id
  internet_gateway_id = aws_internet_gateway.main.id
}
