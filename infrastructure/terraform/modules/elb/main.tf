resource "aws_elb" "my_elb" {
  name            = "my-elb"
  subnets         = [var.subnet_id]
  security_groups = [var.security_group_id]

  listener {
    instance_port      = 5000
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }
}
