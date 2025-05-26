resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = "global-cluster-demo"
  engine                    = "aurora-mysql"
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier        = "global-cluster-primary"
  engine                    = "aurora-mysql"
  engine_mode               = "provisioned"
  master_username           = var.master_username
  master_password           = var.master_password
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids    = [var.security_group_id]
  global_cluster_identifier = aws_rds_global_cluster.this.id
  availability_zones        = var.azs
  backup_retention_period   = 7
  preferred_backup_window   = "07:00-09:00"
}

resource "aws_s3_bucket" "snapshot_backup" {
  bucket        = "rds-snapshot-backup-${random_id.id.hex}"
  force_destroy = true
}

resource "random_id" "id" {
  byte_length = 4
}
