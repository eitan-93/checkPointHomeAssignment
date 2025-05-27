variable "region" {
  type        = string
  default     = "us-east-2"
  description = "The AWS region to use"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

variable "subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "The CIDR block for the subnet"
}

#variable "AWS_ACCESS_KEY_ID" {
#  type = string
#}

#variable "AWS_SECRET_ACCESS_KEY" {
#  type = string
#}