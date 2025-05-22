# resource "aws_rds_global_cluster" "this" {
#   global_cluster_identifier = var.cluster_identifier
#   engine                    = "aurora-mysql"
#   engine_version            = var.engine_version
#   database_name             = replace(var.cluster_identifier, "-", "_")
# }

# resource "aws_rds_cluster" "primary" {
#   provider = aws.primary

#   global_cluster_identifier = aws_rds_global_cluster.this.id
#   cluster_identifier        = "${var.cluster_identifier}-primary"
#   engine                    = aws_rds_global_cluster.this.engine
#   engine_version            = aws_rds_global_cluster.this.engine_version
#   database_name             = aws_rds_global_cluster.this.database_name
#   master_username           = var.master_username
#   master_password           = var.master_password
#   db_subnet_group_name      = var.db_subnet_group_name
#   vpc_security_group_ids    = var.vpc_security_group_ids
#   skip_final_snapshot       = true
#   storage_encrypted         = true

#   lifecycle {
#     ignore_changes = [engine_version]
#   }
# }

# resource "aws_rds_cluster_instance" "primary" {
#   provider           = aws.primary
#   cluster_identifier = aws_rds_cluster.primary.id
#   instance_class     = var.instance_class
#   engine             = aws_rds_cluster.primary.engine
#   engine_version     = aws_rds_cluster.primary.engine_version
# }

# resource "aws_rds_cluster" "replica" {
#   provider = aws.replica

#   global_cluster_identifier = aws_rds_global_cluster.this.id
#   cluster_identifier        = "${var.cluster_identifier}-replica"
#   engine                    = aws_rds_global_cluster.this.engine
#   engine_version            = aws_rds_global_cluster.this.engine_version
#   source_region             = var.primary_region
#   db_subnet_group_name      = var.db_subnet_group_name
#   vpc_security_group_ids    = var.vpc_security_group_ids
#   storage_encrypted         = true

#   depends_on = [aws_rds_cluster_instance.primary]
# }

# resource "aws_rds_cluster_instance" "replica" {
#   provider           = aws.replica
#   cluster_identifier = aws_rds_cluster.replica.id
#   instance_class     = var.instance_class
#   engine             = aws_rds_cluster.replica.engine
#   engine_version     = aws_rds_cluster.replica.engine_version
# }
resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.cluster_identifier
  engine                    = "aurora-mysql"
  engine_version            = var.engine_version
  database_name             = replace(var.cluster_identifier, "-", "_")
}

resource "aws_rds_cluster" "primary" {
  provider = aws.primary

  global_cluster_identifier = aws_rds_global_cluster.this.id
  cluster_identifier        = "${var.cluster_identifier}-primary"
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  database_name             = aws_rds_global_cluster.this.database_name
  master_username           = var.master_username
  master_password           = var.master_password
  db_subnet_group_name      = var.db_subnet_group_name
  vpc_security_group_ids    = var.vpc_security_group_ids
  storage_encrypted         = true
  skip_final_snapshot       = true
  deletion_protection       = var.environment == "prod"
}

resource "aws_rds_cluster_instance" "primary" {
  provider           = aws.primary
  count              = 1
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.primary.engine
  engine_version     = aws_rds_cluster.primary.engine_version
}

resource "aws_rds_cluster" "replica" {
  provider = aws.replica

  global_cluster_identifier = aws_rds_global_cluster.this.id
  cluster_identifier        = "${var.cluster_identifier}-replica"
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  source_region             = var.primary_region
  db_subnet_group_name      = var.db_subnet_group_name
  vpc_security_group_ids    = var.vpc_security_group_ids
  storage_encrypted         = true
  skip_final_snapshot       = true
  deletion_protection       = var.environment == "prod"

  depends_on = [aws_rds_cluster_instance.primary]
}

resource "aws_rds_cluster_instance" "replica" {
  provider           = aws.replica
  count              = 1
  cluster_identifier = aws_rds_cluster.replica.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.replica.engine
  engine_version     = aws_rds_cluster.replica.engine_version
}