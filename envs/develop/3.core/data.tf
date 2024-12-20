locals {
  # vpc
  vpc_name = "${var.service_name}-${var.env}-vpc"

  # sg
  sg_alb_name = "${var.service_name}-${var.env}-gateway-alb-sg"

  # ssm
  ssm_cloudfront_access_control_header_value = "${local.ssm_parameter_store_prefix}/CLOUDFRONT/ACCESS_CONTROL_HEADER/VALUE"
}

###########################################
# data参照
###########################################
data "aws_vpc" "wanrun" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

// VPC内の全サブネットを取得
data "aws_subnets" "vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.wanrun]
  }
}

// Publicのsubnetsを取得
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.wanrun.id

  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

// Privateのsubnetsを取得
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.wanrun.id

  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

// alb sgの取得
data "aws_security_group" "alb_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.wanrun.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.sg_alb_name]
  }
}

// cloudfrontのアクセスコントロールヘッダーの参照
data "aws_ssm_parameter" "cloudfront_access_control_header_value" {
  name = local.ssm_cloudfront_access_control_header_value
}
