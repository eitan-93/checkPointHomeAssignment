provider "aws" {
  alias = "main"
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}



module "github_actions" {
  source = "./modules/github_actions"

  repository = "my-repo"
  aws_access_key_id_secret_name = "AWS_ACCESS_KEY_ID_LOCALSTACK"
  aws_secret_access_key_secret_name = "AWS_SECRET_ACCESS_KEY_LOCALSTACK"
}

module "elb" {
  source = "./modules/elb"

  subnets         = [aws_subnet.my_subnet.id]
  security_groups = [aws_security_group.my_security_group.id]
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name = "my-cluster"
  instance_type = "t2.micro"
  key_pair      = "my-key-pair"
  security_groups = [aws_security_group.my_security_group.id]
  subnet_ids     = [aws_subnet.my_subnet.id]
}

module "s3" {
  source = "./modules/s3"

  bucket_name = "my-bucket"
}

module "ssm" {
  source = "./modules/ssm"

  parameter_name = "token"
  parameter_value = "my-token-value"
}

module "sqs" {
  source = "./modules/sqs"

  queue_name = "my-queue"
}