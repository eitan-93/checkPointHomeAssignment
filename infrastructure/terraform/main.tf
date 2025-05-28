terraform {
  backend "s3" {
    bucket         = "eitantestbucket"
    key            = "infrastructure/terraform/terraform.tfstate"
    region         = "us-east-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.5.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Security group for my ELB"
  vpc_id      = data.aws_vpc.default.id

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

module "elb" {
  source = "./modules/elb"

  subnet_id          = data.aws_subnets.default.ids[0]
  security_group_id  = aws_security_group.my_security_group.id
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.my_security_group.id]
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

module "ecs" {
  source = "./modules/ecs"

  cluster_name    = "my-cluster"
  instance_type   = "t2.micro"
  key_pair        = "my-key-pair"
  security_groups = [aws_security_group.my_security_group.id]
  subnet_ids      = data.aws_subnets.default.ids
  sqs_queue_url   = module.sqs.queue_url
  elb_name         = module.elb.elb_name
  currencyfreaks_api_key = var.currencyfreaks_api_key
}


output "security_group_id" {
  value = aws_security_group.my_security_group.id
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}