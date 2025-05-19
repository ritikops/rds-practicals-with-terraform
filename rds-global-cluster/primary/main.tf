provider "aws" {
  region = "us-east-1"
}

// ...existing code...

# Create a KMS Key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id] # Replace with your subnet resources

  tags = {
    Name = "RDS subnet group"
  }
}

# Create a Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.main.id # Replace with your VPC resource

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["192.0.0.0/16"] # Adjust as needed
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

# Example VPC and Subnets (if not already defined)
resource "aws_vpc" "main" {
  cidr_block = "192.0.0.0/16"
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.0.2.0/24"
  availability_zone = "us-east-1b"
}

// ...existing code...

resource "aws_rds_global_cluster" "global" {
  global_cluster_identifier = var.global_cluster_id
  engine                    = var.db_engine
  engine_version            = var.engine_version
  storage_encrypted         = true
  database_name             = var.db_name

}

resource "aws_rds_cluster" "primary" {
  cluster_identifier        = var.db_identifier
  engine                    = var.db_engine
  engine_version            = var.engine_version
  master_username           = "admin"
  master_password           = "password1234"
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  backup_retention_period   = 7
  preferred_backup_window   = var.backup_window
  kms_key_id                = aws_kms_key.rds.arn
  global_cluster_identifier = aws_rds_global_cluster.global.id
  storage_encrypted         = true
  skip_final_snapshot       = true

}

resource "aws_rds_cluster_instance" "writer" {
  identifier           = "${var.db_identifier}-instance-1"
  cluster_identifier   = aws_rds_cluster.primary.id
  instance_class       = var.instance_class
  engine               = var.db_engine
  engine_version       = var.engine_version
  publicly_accessible  = false
  db_subnet_group_name = var.db_subnet_group_name

}
