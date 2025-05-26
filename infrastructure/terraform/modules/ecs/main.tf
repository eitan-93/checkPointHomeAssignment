resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_service" "microservice1" {
  name            = "microservice1"
  cluster         = aws_ecs_cluster.my_cluster.name
  task_definition = aws_ecs_task_definition.microservice1.arn
  desired_count   = 1
}

resource "aws_ecs_service" "microservice2" {
  name            = "microservice2"
  cluster         = aws_ecs_cluster.my_cluster.name
  task_definition = aws_ecs_task_definition.microservice2.arn
  desired_count   = 1
}

resource "aws_ecs_task_definition" "microservice1" {
  family                = "microservice1"
  container_definitions = jsonencode([
    {
      name      = "microservice1"
      image      = "microservice1:latest"
      cpu        = 10
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "microservice2" {
  family                = "microservice2"
  container_definitions = jsonencode([
    {
      name      = "microservice2"
      image      = "microservice2:latest"
      cpu        = 10
      essential = true
      portMappings = [
        {
          containerPort = 5001
          hostPort      = 5001
        }
      ]
    }
  ])
}