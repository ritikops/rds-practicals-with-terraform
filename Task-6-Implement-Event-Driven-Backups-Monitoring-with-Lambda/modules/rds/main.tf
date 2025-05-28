terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }

  }
}
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}
resource "aws_subnet" "this-subnet" {
  count      = length(var.subnet_cidrs)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidrs[count.index]
  # cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = var.tags
}
resource "aws_db_subnet_group" "subnet-group" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = aws_subnet.this-subnet[*].id
  tags       = var.tags
}
resource "aws_security_group" "rds-sg" {
  name        = "${var.cluster_name}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_parameter_group" "default" {
  name   = "${var.cluster_name}-db-parameter-group"
  family = "aurora-mysql8.0"
  tags   = var.tags

  # parameter {
  #   name  = "character_set_server"
  #   value = "utf8mb4"
  # }

  # parameter {
  #   name  = "collation_server"
  #   value = "utf8mb4_unicode_ci"
  # }


}
resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "aws_subnet" "secondary_subnet" {
  provider          = aws.secondary
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = "${var.secondary_region}${element(["a", "b"], count.index)}"
  tags              = var.tags
}

resource "aws_db_subnet_group" "secondary_subnet_group" {
  provider   = aws.secondary
  name       = "secondary-subnet-group"
  subnet_ids = aws_subnet.secondary_subnet[*].id
  tags       = var.tags
}


resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.cluster_name
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.0"
}


resource "aws_security_group" "secondary_rds_sg" {
  provider    = aws.secondary
  name        = "${var.cluster_name}-secondary-rds-sg"
  description = "Security group for secondary RDS instances"
  vpc_id      = aws_vpc.secondary_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_rds_cluster_parameter_group" "secondary" {
  provider    = aws.secondary
  family      = "aurora-mysql8.0"
  name        = "${var.cluster_name}-cluster-parameter-group"
  description = "Cluster parameter group for secondary Aurora cluster"
  tags        = var.tags
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier        = "${var.cluster_name}-primary"
  engine                    = "aurora-mysql"
  engine_mode               = "provisioned"
  engine_version            = "8.0.mysql_aurora.3.04.0"
  global_cluster_identifier = aws_rds_global_cluster.this.id
  master_username           = "admin"
  master_password           = "example-password"
  backup_retention_period   = 7
  skip_final_snapshot       = true
  db_subnet_group_name      = aws_db_subnet_group.subnet-group.name
  # storage_encrypted         = true
  apply_immediately = true
  # publicly_accessible       = false
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  tags                   = var.tags
}

resource "aws_rds_cluster_instance" "primary_instances" {
  count                      = var.primary_instance_count
  identifier                 = "${var.global_cluster_identifier}-primary-${count.index}"
  cluster_identifier         = aws_rds_cluster.primary.id
  instance_class             = var.primary_instance_class
  engine                     = var.engine
  publicly_accessible        = false
  auto_minor_version_upgrade = true
  db_parameter_group_name    = var.db_parameter_group_name
  tags                       = var.tags
}

resource "aws_rds_cluster" "secondary" {
  # cluster_identifier              = "${var.global_cluster_identifier}-secondary"
  cluster_identifier              = "${var.cluster_name}-secondary"
  provider                        = aws.secondary
  engine                          = var.engine
  engine_version                  = var.engine_version
  db_subnet_group_name            = aws_db_subnet_group.secondary_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.secondary_rds_sg.id]
  skip_final_snapshot             = true
  apply_immediately               = true
  global_cluster_identifier       = aws_rds_global_cluster.this.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.secondary.name
  # storage_encrypted               = true
  source_region = var.primary_region
  tags          = var.tags
}

resource "aws_rds_cluster_instance" "secondary_instances" {
  provider                   = aws.secondary
  count                      = var.secondary_instance_count
  identifier                 = "${var.cluster_name}-secondary-${count.index}"
  cluster_identifier         = aws_rds_cluster.secondary.id
  instance_class             = var.secondary_instance_class
  depends_on                 = [aws_rds_cluster.secondary]
  engine                     = var.engine
  publicly_accessible        = false
  auto_minor_version_upgrade = true
  db_parameter_group_name    = var.db_parameter_group_name
  tags                       = var.tags
}


