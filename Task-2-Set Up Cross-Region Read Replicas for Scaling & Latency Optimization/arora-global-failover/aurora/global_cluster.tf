resource "aws_rds_global_cluster" "global" {
  provider                  = aws.primary
  global_cluster_identifier = var.global_cluster_id
  engine                    = var.db_engine
  engine_version            = var.engine_version
  storage_encrypted         = true
}
