# resource "aws_rds_cluster" "primary" {
#   name       = "primary-subnet-group"
#   subnet_ids = var.primary_subnet_ids 
#   cluster_identifier      = "aurora-cluster-primary"
#   engine                  = var.db_engine
#   engine_version          = var.engine_version
#   master_username         = var.db_username
#   master_password         = var.db_password
#   database_name           = var.db_name
#   db_subnet_group_name    = aws_db_subnet_group.aurora.name
#   availability_zones      = ["us-east-1a", "us-east-1b"]
#   skip_final_snapshot     = true
# }

# resource "aws_rds_cluster" "secondary" {
#   name       = "secondary-subnet-group"
#   subnet_ids = var.secondary_subnet_ids
#   cluster_identifier      = "aurora-cluster-secondary"
#   engine                  = var.db_engine
#   engine_version          = var.engine_version
#   global_cluster_identifier = var.global_cluster_id
#   db_subnet_group_name    = aws_db_subnet_group.aurora.name
#   availability_zones      = ["us-west-2a", "us-west-2b"]
#   skip_final_snapshot     = true
# }

# resource "aws_db_subnet_group" "aurora" {
#   name       = "aurora-subnet-group"
#   subnet_ids = var.subnet_ids

#   tags = {
#     Name = "Aurora DB Subnet Group"
#   }
# }
# resource "aws_vpc" "secondary" {
#   provider   = aws.secondary
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "Secondary VPC"
#   }
# }
# resource "aws_subnet" "secondary_a" {
#   provider          = aws.secondary
#   vpc_id            = var.secondary_vpc_id
#   cidr_block        = "10.0.1.0/25"
#   availability_zone = "us-west-2a"
# }

# resource "aws_subnet" "secondary_b" {
#   provider          = aws.secondary
#   vpc_id            = var.secondary_vpc_id
#   cidr_block        = "10.0.2.0/25"
#   availability_zone = "us-west-2b"
# }

resource "aws_db_subnet_group" "primary" {
  name       = "aurora-primary-subnet-group"
  subnet_ids = var.primary_subnet_ids

  tags = {
    Name = "Aurora Primary DB Subnet Group"
  }
}

resource "aws_db_subnet_group" "secondary" {
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

resource "aws_rds_cluster" "primary" {
  cluster_identifier      = "aurora-cluster-primary"
  engine                  = var.db_engine
  engine_version          = var.engine_version
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.primary.name
  availability_zones      = ["us-east-1a", "us-east-1b"]
  skip_final_snapshot     = true
}
resource "aws_rds_cluster_instance" "primary_inst" {
  provider           = aws.primary
  identifier         = "${var.global_cluster_id}-primary"
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class     = var.instance_class
  engine             = var.db_engine
}

resource "aws_rds_cluster" "secondary" {
  cluster_identifier        = "aurora-cluster-secondary"
  engine                    = var.db_engine
  engine_version            = var.engine_version
  global_cluster_identifier = var.global_cluster_id
  db_subnet_group_name      = aws_db_subnet_group.secondary.name
  availability_zones        = ["us-west-2a", "us-west-2b"]
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "secondary_inst" {
  provider           = aws.secondary
  identifier         = "${var.global_cluster_id}-secondary-1"
  cluster_identifier = aws_rds_cluster.secondary.id
  instance_class     = var.instance_class
  engine             = var.db_engine
}
