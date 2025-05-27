variable "master_username" {
  default = "admin"
}

variable "master_password" {
  default = "Password1234!"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "azs" {
  type = list(string)
}
variable "cluster_name" {}
variable "primary_region" {}
variable "secondary_region" {}
variable "tags" {
  type = map(string)
}
