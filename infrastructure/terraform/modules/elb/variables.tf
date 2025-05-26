variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}