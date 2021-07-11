variable "instance_prefix" {
  description = "Prefix for db instance"
  type = string
}

variable "storage" {
  description = "Storage amount for the db instance"
  type = number
}

variable "instance_class" {
  description = "The instance class type"
  type = string
}

variable "db_name" {
  description = "The name of the databse"
  type = string
}

variable "username" {
  description = "The db username"
  type = string
}

variable "db_password" {
  description = "The password for teh database"
  type = string
}

variable "db_security_group_name" {
  description = "The database security group name"
  type = string
}