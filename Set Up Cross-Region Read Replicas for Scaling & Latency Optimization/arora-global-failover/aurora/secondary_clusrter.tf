resource "aws_rds_cluster" "secondary" {
  provider                  = aws.secondary
  cluster_identifier        = "${var.global_cluster_id}-secondary"
  engine                    = var.db_engine
  engine_version            = var.engine_version
  db_subnet_group_name      = aws_db_subnet_group.aurora.name
  global_cluster_identifier = aws_rds_global_cluster.global.id
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "secondary_inst" {
  provider           = aws.secondary
  identifier         = "${var.global_cluster_id}-secondary-1"
  cluster_identifier = aws_rds_cluster.secondary.id
  instance_class     = var.instance_class
}
