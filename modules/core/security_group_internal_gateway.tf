#######################################################################
# Security Group (internal gateway)
#######################################################################
resource "aws_security_group" "internal_gateway" {
  name        = "${var.service_name}-${var.env}-internal-gateway-alb-sg"
  vpc_id      = var.vpc_id
  description = "${var.service_name}-${var.env}-internal-gateway-alb-sg"

  tags = {
    Name = "${var.service_name}-${var.env}-internal-gateway-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront_managed_prefix_list" {
  security_group_id            = aws_security_group.internal_gateway.id
  description                  = "Allow CloudFront IPs"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = data.aws_security_group.vpc_origin_sg.id

  # NOTE: VPC OriginのセキュリティグループID取得後にインバウンドルールに紐付けるため、depends_onでVPC Originのセキュリティグループのデータリソースを指定
  depends_on = [data.aws_security_group.vpc_origin_sg]
}

# NOTE: CloudFront-VPCOrigins-Service-SGのセキュリティグループIDの取得
data "aws_security_group" "vpc_origin_sg" {
  filter {
    name   = "group-name"
    values = ["CloudFront-VPCOrigins-Service-SG"]
  }

  # NOTE: VPC Origin作成時に作られるセキュリティグループIDを取得するため、depends_onでVPC Originのリソースを指定
  depends_on = [aws_cloudfront_vpc_origin.main_internal_alb]
}
