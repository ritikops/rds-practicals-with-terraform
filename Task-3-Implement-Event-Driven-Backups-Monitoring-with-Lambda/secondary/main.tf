terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
    }
  }
}
resource "aws_vpc" "secondary" {
  cidr_block = "192.1.0.0/16"
}

# Subnets for DB
resource "aws_subnet" "secondary1" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "192.1.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "secondary2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "192.1.2.0/24"
  availability_zone = "eu-west-1b"
}

# Subnet group 2
resource "aws_db_subnet_group" "secondary" {
  name       = "rds-secondary-subnet-group"
  subnet_ids = [aws_subnet.secondary1.id, aws_subnet.secondary2.id]

  tags = {
    Name = "RDS secondary subnet group"
  }
}

# Security group 2
resource "aws_security_group" "secondary" {
  name        = "rds-secondary-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.secondary.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["192.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS secondary security group"
  }
}

# KMS key 2
resource "aws_kms_key" "secondary" {
  description             = "KMS key for RDS encryption (secondary)"
  deletion_window_in_days = 7
}

# Join global cluster as reader
resource "aws_rds_cluster" "secondary" {
  cluster_identifier        = var.db_identifier
  engine                    = var.db_engine
  engine_version            = var.engine_version
  db_subnet_group_name      = aws_db_subnet_group.secondary.name
  vpc_security_group_ids    = [aws_security_group.secondary.id]
  kms_key_id                = aws_kms_key.secondary.arn
  global_cluster_identifier = var.global_cluster_id
  source_region             = "us-east-1"
  storage_encrypted         = true
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "reader" {
  identifier           = "${var.db_identifier}-replica-1"
  cluster_identifier   = aws_rds_cluster.secondary.id
  instance_class       = var.instance_class
  engine               = var.db_engine
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.secondary.name
  engine_version       = var.engine_version
}