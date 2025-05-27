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

#local test
#provider "aws" {
#  region                      = "us-east-2"
#  #FOR TESTING
#  access_key = "test"
#  secret_key = "test"
#  skip_credentials_validation = true
#  skip_metadata_api_check     = true
#  skip_requesting_account_id  = true
#  s3_use_path_style           = true
#  endpoints {
#    s3             = "http://localhost:4566"
#    ec2            = "http://localhost:4566"
#    iam            = "http://localhost:4566"
#    sts            = "http://localhost:4566"
#    elb            = "http://localhost:4566"
#    ssm            = "http://localhost:4566"
#    sqs            = "http://localhost:4566"
#    ecs            = "http://localhost:4566"
#    cloudwatch     = "http://localhost:4566"
#    autoscaling    = "http://localhost:4566"
#  }
#
#  shared_credentials_files = ["/dev/null"]
#
#  token                   = "dummy"
#  
#}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
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


module "github_actions" {
  source = "./modules/github_actions"

  repository = "eitan-93/checkPointHomeAssignment"
  aws_access_key_id_secret_name = "AWS_ACCESS_KEY_ID"
  aws_secret_access_key_secret_name = "AWS_SECRET_ACCESS_KEY"
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name    = "my-cluster"
  instance_type   = "t2.micro"
  key_pair        = "my-key-pair"
  security_groups = [aws_security_group.my_security_group.id]
  subnet_ids      = data.aws_subnets.default.ids
}

#module "s3" {
#  source = "./modules/s3"
#  bucket_name = "eitantestbucket"
#}

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

#output "subnet_ids" {
#  value = aws_subnets.default.ids
#}


output "security_group_id" {
  value = aws_security_group.my_security_group.id
}