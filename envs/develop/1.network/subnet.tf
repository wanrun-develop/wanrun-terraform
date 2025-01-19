data "aws_availability_zones" "available" {}

###########################################
# Public
###########################################
resource "aws_subnet" "public_subnets" {
  for_each = { for az in data.aws_availability_zones.available.names : element(split("-", az), length(split("-", az)) - 1) => az }


  vpc_id            = aws_vpc.wanrun.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(data.aws_availability_zones.available.names, each.value) * 2)
  availability_zone = each.key

  tags = {
    Name = "${var.service_name}-${var.env}-public-subnet-${each.key}"
    Tier = "Public"
  }
}

###########################################
# Private
###########################################
resource "aws_subnet" "private_subnets" {
  for_each = { for az in data.aws_availability_zones.available.names : element(split("-", az), length(split("-", az)) - 1) => az }

  vpc_id            = aws_vpc.wanrun.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(data.aws_availability_zones.available.names, each.value) * 2 + 1)
  availability_zone = each.key

  tags = {
    Name = "${var.service_name}-${var.env}-private-subnet-${each.key}"
    Tier = "Private"
  }
}
