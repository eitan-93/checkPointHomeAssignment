# Configure the AWS provider
provider "aws" {
  region = "us-east-2"
}

# Create an IAM role for the GitHub Actions workflow
resource "aws_iam_role" "github_actions" {
  name        = "github-actions-role"
  description = "Role for GitHub Actions workflow"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "github-actions.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

# Create an IAM policy for the GitHub Actions workflow
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-policy"
  description = "Policy for GitHub Actions workflow"

  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
        ]
        Effect = "Allow"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# Create a GitHub Actions workflow that uses the AWS CLI with the assumed IAM role
resource "github_actions_workflow" "example" {
  name        = "example-workflow"
  repository  = "my-repo"
  workflow    = file("${path.module}/example-workflow.yml")
}

# Use the secrets stored in the GitHub Secrets manager
data "github_actions_secret" "aws_access_key_id" {
  name        = "AWS_ACCESS_KEY_ID_LOCALSTACK"
  repository  = "my-repo"
}

data "github_actions_secret" "aws_secret_access_key" {
  name        = "AWS_SECRET_ACCESS_KEY_LOCALSTACK"
  repository  = "my-repo"
}



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

module "elb" {
  source = "checkPointHomeAssignment/infrastructure/terraform"

  subnets         = [aws_subnet.my_subnet.id]
  security_groups = [aws_security_group.my_security_group.id]
}

module "ecs" {
  source = "checkPointHomeAssignment/infrastructure/terraform"

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