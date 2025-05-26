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

resource "aws_elb" "my_elb" {
  name            = "my-elb"
  subnets         = [aws_subnet.my_subnet.id]
  security_groups = [aws_security_group.my_security_group.id]

  listener {
    instance_port      = 5000
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }
}