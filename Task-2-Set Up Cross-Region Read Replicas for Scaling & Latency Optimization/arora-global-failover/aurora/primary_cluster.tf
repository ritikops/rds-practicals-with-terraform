resource "aws_rds_cluster" "primary" {
  depends_on = [aws_rds_global_cluster.global]

  cluster_identifier      = "aurora-cluster-primary"
  provider = aws.primary
  engine                  = var.db_engine
  engine_version          = var.engine_version
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.primary.name
  global_cluster_identifier = var.global_cluster_id
  availability_zones      = ["us-east-1a", "us-east-1b"]
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "primary_writer" {
  provider           = aws.primary
  identifier         = "${var.global_cluster_id}-primary"
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class     = var.instance_class
  engine             = var.db_engine
}