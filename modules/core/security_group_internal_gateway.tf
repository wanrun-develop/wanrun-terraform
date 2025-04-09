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

resource "aws_vpc_security_group_ingress_rule" "internal_gateway" {
  security_group_id            = aws_security_group.internal_gateway.id
  description                  = "Allow VPC Origin"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = data.aws_security_group.vpc_origin_sg.id

  # NOTE: VPC OriginのセキュリティグループID取得後にインバウンドルールに紐付けるため、depends_onでVPC Originのセキュリティグループのデータリソースを指定
  depends_on = [data.aws_security_group.vpc_origin_sg]
}

resource "aws_vpc_security_group_egress_rule" "internal_gateway" {
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  description = "Allow all"

  security_group_id = aws_security_group.internal_gateway.id

  tags = {
    Name = "${var.service_name}-${var.env}-internal-gateway-alb-sg"
  }
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

resource "aws_vpc_security_group_ingress_rule" "ssr_lambda" {
  security_group_id            = aws_security_group.internal_gateway.id
  description                  = "Allow SSR Lambda"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = element(var.lambda_sg_ids, 0)

  depends_on = [aws_lambda_function.internal_wanrun_ssr]
}
