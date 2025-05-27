resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.cluster_name
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.0"
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier        = "${var.cluster_name}-primary"
  engine                    = "aurora-mysql"
  engine_mode               = "provisioned"
  global_cluster_identifier = aws_rds_global_cluster.this.id
  master_username           = "admin"
  master_password           = "example-password"
  backup_retention_period   = 7
  skip_final_snapshot       = true
  db_subnet_group_name      = aws_db_subnet_group.this.name
  storage_encrypted         = true
  apply_immediately         = true
  # publicly_accessible       = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  tags                   = var.tags
}
