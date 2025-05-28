# resource "aws_rds_cluster" "aurora" {
#   cluster_identifier      = "aurora-cluster"
#   engine                  = "aurora-mysql"
#   engine_mode             = "provisioned"
#   master_username         = var.db_username
#   master_password         = var.db_password
#   database_name           = var.db_name
#   vpc_security_group_ids  = [var.db_sg_id]
#   db_subnet_group_name    = var.subnet_group_name
#   skip_final_snapshot     = true
# }

# resource "aws_rds_cluster_instance" "writer" {
#   identifier              = "aurora-writer"
#   cluster_identifier      = aws_rds_cluster.aurora.id
#   instance_class          = var.db_instance_class
#   engine                  = aws_rds_cluster.aurora.engine
# }

# resource "aws_rds_cluster_instance" "read_replicas" {
#   count                   = var.initial_read_replica_count
#   identifier              = "aurora-reader-${count.index}"
#   cluster_identifier      = aws_rds_cluster.aurora.id
#   instance_class          = var.db_instance_class
#   engine                  = aws_rds_cluster.aurora.engine
# }
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
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  publicly_accessible = false
  promotion_tier     = 0
}

resource "aws_rds_cluster_instance" "read_replicas" {
  count              = var.initial_read_replica_count
  identifier         = "aurora-reader-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  publicly_accessible = false
  promotion_tier     = 1
}

resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "Aurora subnet group"
  }
}
