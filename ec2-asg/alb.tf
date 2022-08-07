resource "aws_security_group" "lb-sg" {
  name   = "load-balancer-sg"
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
  tags = {
    Name = "alb-sg"
  }
}
resource "aws_lb" "ec2-loadbalancer" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet-1.id, aws_subnet.public_subnet-2.id]
  security_groups    = [aws_security_group.lb-sg.id]

}

resource "aws_lb_target_group" "lb-target-group" {
  name     = "lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.ec2-loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type                  = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }

}