resource "aws_rds_cluster" "secondary" {
  depends_on = [ 
    aws_rds_cluster.primary,
    aws_rds_cluster_instance.primary_writer
   ]
  provider = aws.secondary
  cluster_identifier        = "aurora-cluster-secondary"
  engine                    = var.db_engine
  engine_version            = var.engine_version
  global_cluster_identifier = var.global_cluster_id
  db_subnet_group_name      = aws_db_subnet_group.secondary.name
  availability_zones        = ["us-west-2a", "us-west-2b"]
  skip_final_snapshot       = true
  master_username           = var.db_username
  master_password           = var.db_password

}

resource "aws_rds_cluster_instance" "secondary_inst" {
  provider           = aws.secondary
  identifier         = "${var.global_cluster_id}-secondary-1"
  cluster_identifier = aws_rds_cluster.secondary.id
  instance_class     = var.instance_class
  engine             = var.db_engine
}