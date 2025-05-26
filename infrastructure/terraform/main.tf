provider "aws" {
  alias = "main"
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "my_subnet" {
  cidr_block = var.subnet_cidr_block
  vpc_id     = aws_vpc.my_vpc.id
  availability_zone = "us-east-2"
}

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Security group for my ELB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



module "github_actions" {
  source = "./modules/github_actions"

  repository = "my-repo"
  aws_access_key_id_secret_name = "AWS_ACCESS_KEY_ID_LOCALSTACK"
  aws_secret_access_key_secret_name = "AWS_SECRET_ACCESS_KEY_LOCALSTACK"
}

module "elb" {
  source = "./modules/elb"

  subnet_id         = aws_subnet.my_subnet.id
  security_group_id = aws_security_group.my_security_group.id
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

output "subnet_id" {
  value = aws_subnet.my_subnet.id
}

output "security_group_id" {
  value = aws_security_group.my_security_group.id
}