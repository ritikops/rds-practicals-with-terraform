# resource "aws_db_subnet_group" "aurora" {
#   name       = "aurora-subnet-group"
#   subnet_ids = concat(
#     var.primary_subnet_ids,
#     var.secondary_subnet_ids
#   )
# }
