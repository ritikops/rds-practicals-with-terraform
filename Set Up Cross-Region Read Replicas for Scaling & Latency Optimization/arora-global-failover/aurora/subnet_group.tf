resource "aws_db_subnet_group" "primary" {
  name       = "aurora-primary-subnet-group"
  subnet_ids = var.primary_subnet_ids

  tags = {
    Name = "Aurora Primary DB Subnet Group"
  }
}

resource "aws_db_subnet_group" "secondary" {
  provider = aws.secondary
  name       = "aurora-secondary-subnet-group"
  subnet_ids = var.secondary_subnet_ids
  # subnet_ids = [
  #   aws_subnet.secondary_a.id,
  #   aws_subnet.secondary_b.id
  # ]

  tags = {
    Name = "Aurora Secondary DB Subnet Group"
  }
}