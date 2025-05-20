resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = concat(
    aws_subnet.primary.*.id,
    aws_subnet.secondary.*.id
  )
}
