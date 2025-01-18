###########################################
# Public
###########################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wanrun.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.service_name}-${var.env}-public-rt"
  }

  depends_on = [aws_vpc.wanrun]
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}


###########################################
# Private
###########################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.wanrun.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    "Name" = "${var.service_name}-${var.env}-private-rt"
  }

  depends_on = [aws_vpc.wanrun]
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route_table.private]
}
