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
