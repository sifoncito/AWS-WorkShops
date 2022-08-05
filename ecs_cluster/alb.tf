resource "aws_lb" "ecs-lb" {
  name               = "ecs-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [aws_subnet.main1.id, aws_subnet.main2.id]
}

resource "aws_security_group" "lb-sg" {
  name   = "allow-all"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_lb_target_group" "lb-target-group" {
  name        = "lbtg-ecs"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "ecs-listner" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }

}