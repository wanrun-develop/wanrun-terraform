locals {
  # vpc
  vpc_name = "${var.service_name}-${var.env}-vpc"

  # route53
  route53_zone_name = "wanrun.jp"

  # acm
  acm_name = "wanrun.jp"
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
    values = [data.aws_vpc.wanrun.id]
  }
}

// Publicのsubnetsを取得
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.wanrun.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

// Privateのsubnetsを取得
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.wanrun.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_route53_zone" "wanrun_jp" {
  provider = aws.virginia

  name         = local.route53_zone_name
  private_zone = false
}

data "aws_acm_certificate" "wanrun_jp" {
  provider = aws.virginia
  domain   = local.acm_name
}
