resource "aws_subnet" "public_subnet_1a" {
  vpc_id     = aws_vpc.wanrun.id
  cidr_block = var.subnets_cidr["public_subnet_1a"]

  tags = {
    Name = "${var.service_name}-${var.env}-public-subnet-1a"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id     = aws_vpc.wanrun.id
  cidr_block = var.subnets_cidr["public_subnet_1c"]

  tags = {
    Name = "${var.service_name}-${var.env}-public-subnet-1c"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_subnet_1d" {
  vpc_id     = aws_vpc.wanrun.id
  cidr_block = var.subnets_cidr["public_subnet_1d"]

  tags = {
    Name = "${var.service_name}-${var.env}-public-subnet-1d"
    Tier = "Public"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = aws_vpc.wanrun.id
  cidr_block = var.subnets_cidr["private_subnet_1a"]

  tags = {
    Name = "${var.service_name}-${var.env}-private-subnet-1a"
    Tier = "Private"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id     = aws_vpc.wanrun.id
  cidr_block = var.subnets_cidr["private_subnet_1c"]

  tags = {
    Name = "${var.service_name}-${var.env}-private-subnet-1c"
    Tier = "Private"
  }
}

resource "aws_subnet" "private_subnet_1d" {
  vpc_id     = aws_vpc.wanrun.id
  cidr_block = var.subnets_cidr["private_subnet_1d"]

  tags = {
    Name = "${var.service_name}-${var.env}-private-subnet-1d"
    Tier = "Private"
  }
}
