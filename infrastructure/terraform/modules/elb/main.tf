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