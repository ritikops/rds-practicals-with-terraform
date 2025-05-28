resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  vpc_security_group_ids  = [var.db_sg_id]
  db_subnet_group_name    = var.subnet_group_name
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "writer" {
  identifier              = "aurora-writer"
  cluster_identifier      = aws_rds_cluster.aurora.id
  instance_class          = var.db_instance_class
  engine                  = aws_rds_cluster.aurora.engine
}

resource "aws_rds_cluster_instance" "read_replicas" {
  count                   = var.initial_read_replica_count
  identifier              = "aurora-reader-${count.index}"
  cluster_identifier      = aws_rds_cluster.aurora.id
  instance_class          = var.db_instance_class
  engine                  = aws_rds_cluster.aurora.engine
}
