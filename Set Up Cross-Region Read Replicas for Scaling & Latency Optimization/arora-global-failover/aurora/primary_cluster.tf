# resource "aws_rds_cluster" "primary" {
#   provider                  = aws.primary
#   cluster_identifier        = "${var.global_cluster_id}-primary"
#   engine                    = var.db_engine
#   engine_version            = var.engine_version
#   database_name             = var.db_name
#   master_username           = var.db_username
#   master_password           = var.db_password
#   db_subnet_group_name      = aws_db_subnet_group.aurora.name
#   global_cluster_identifier = aws_rds_global_cluster.global.id
#   skip_final_snapshot       = true
# }

# resource "aws_rds_cluster_instance" "primary_inst" {
#   provider           = aws.primary
#   identifier         = "${var.global_cluster_id}-primary-1"
#   cluster_identifier = aws_rds_cluster.primary.id
#   instance_class     = var.instance_class
#   engine             = var.db_engine
# }
