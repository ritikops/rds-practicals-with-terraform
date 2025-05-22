# Primary VPC
resource "aws_vpc" "primary" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "primary-vpc"
  }
}

# Secondary VPC
resource "aws_vpc" "secondary" {
  provider             = aws.secondary
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "secondary-vpc"
  }
}

# Primary Subnets
resource "aws_subnet" "primary_a" {
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "primary-subnet-a"
  }
}

resource "aws_subnet" "primary_b" {
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "primary-subnet-b"
  }
}

# Secondary Subnets
resource "aws_subnet" "secondary_a" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "us-west-2a"
  tags = {
    Name = "secondary-subnet-a"
  }
}

resource "aws_subnet" "secondary_b" {
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-west-2b"
  tags = {
    Name = "secondary-subnet-b"
  }
}

# Internet Gateways
resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
  tags = {
    Name = "primary-igw"
  }
}

# resource "aws_internet_gateway" "secondary" {
#   provider = aws.secondary
#   vpc_id   = aws_vpc.secondary.id
#   tags = {
#     Name = "secondary-igw"
#   }
# }

# Route Tables and Associations (optional, if internet access is needed)
resource "aws_route_table" "primary" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }
  tags = {
    Name = "primary-rt"
  }
}

resource "aws_route_table_association" "primary_a" {
  subnet_id      = aws_subnet.primary_a.id
  route_table_id = aws_route_table.primary.id
}

resource "aws_route_table_association" "primary_b" {
  subnet_id      = aws_subnet.primary_b.id
  route_table_id = aws_route_table.primary.id
}

# Private Route Table (no IGW route)
resource "aws_route_table" "secondary_private" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  tags = {
    Name = "secondary-private-rt"
  }
}

# Associate private route table with subnets
resource "aws_route_table_association" "secondary_a_private" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_a.id
  route_table_id = aws_route_table.secondary_private.id
}

resource "aws_route_table_association" "secondary_b_private" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_b.id
  route_table_id = aws_route_table.secondary_private.id
}