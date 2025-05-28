resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "rds-vpc"
  }
}

resource "aws_subnet" "private" {
  count                   = 2
  cidr_block              = element(var.private_subnets_cidr, count.index)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}
