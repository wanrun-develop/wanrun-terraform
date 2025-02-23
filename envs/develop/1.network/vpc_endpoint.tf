###########################################
# VPC Endpoint S3
###########################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-northeast-1.s3"

  tags = {
    "Name" = "${var.service_name}-${var.env}-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "private" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private.id
}
