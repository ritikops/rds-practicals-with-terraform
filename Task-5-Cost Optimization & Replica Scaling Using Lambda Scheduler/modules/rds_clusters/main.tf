provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet1_cidr
  availability_zone = var.availability_zone1
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet2_cidr
  availability_zone = var.availability_zone2
}

resource "aws_kms_key" "kms" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
}

resource "aws_db_subnet_group" "rds" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.sg_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS security group"
  }
}

resource "aws_rds_global_cluster" "global" {
  count                     = var.create_global_cluster ? 1 : 0
  global_cluster_identifier = var.global_cluster_id
  engine                    = var.db_engine
  engine_version            = var.engine_version
  storage_encrypted         = true
  database_name             = var.db_name
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier        = var.db_identifier
  engine                    = var.db_engine
  engine_version            = var.engine_version
  master_username           = var.master_username
  master_password           = var.master_password
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  backup_retention_period   = 7
  preferred_backup_window   = var.backup_window
  kms_key_id                = aws_kms_key.kms.arn
  global_cluster_identifier = var.global_cluster_id
  source_region             = var.source_region
  storage_encrypted         = true
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "instance" {
  identifier           = "${var.db_identifier}-${var.role}"
  cluster_identifier   = aws_rds_cluster.cluster.id
  instance_class       = var.instance_class
  engine               = var.db_engine
  engine_version       = var.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.rds.name
}
