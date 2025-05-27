data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_launch_configuration" "ecs_instance" {
  name_prefix               = "ecs-launch-config-"
  image_id                  = data.aws_ami.ecs_ami.id
  instance_type             = var.instance_type
  key_name                  = var.key_pair
  security_groups           = var.security_groups
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/ecs_user_data.sh", {
    cluster_name = var.cluster_name
  }))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name_prefix          = "${var.cluster_name}-asg-"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.ecs_instance.name
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "microservice1" {
  family                   = "microservice1"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"

  container_definitions = jsonencode([
    {
      name      = "microservice1"
      image     = "microservice1:latest"
      cpu       = 10
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "microservice2" {
  family                   = "microservice2"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"

  container_definitions = jsonencode([
    {
      name      = "microservice2"
      image     = "microservice2:latest"
      cpu       = 10
      essential = true
      portMappings = [
        {
          containerPort = 5001
          hostPort      = 5001
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "microservice1" {
  name            = "microservice1"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.microservice1.arn
  desired_count   = 1
  launch_type     = "EC2"
}

resource "aws_ecs_service" "microservice2" {
  name            = "microservice2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.microservice2.arn
  desired_count   = 1
  launch_type     = "EC2"
}
