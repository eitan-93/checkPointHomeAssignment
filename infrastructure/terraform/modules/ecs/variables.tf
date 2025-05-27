variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for ECS instances"
}

variable "key_pair" {
  type        = string
  description = "Key pair name for EC2 instances"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs for EC2 instances"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS instances"
}