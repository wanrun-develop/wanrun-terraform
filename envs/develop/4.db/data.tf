locals {
  # vpc
  vpc_name = "${var.service_name}-${var.env}-vpc"

  # sg
  sg_postgres_on_ec2_name = "${var.service_name}-${var.env}-postgres-on-ec2-sg"
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

// alb sgの取得
data "aws_security_group" "postgres_on_ec2_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.wanrun.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.sg_postgres_on_ec2_name]
  }
}
