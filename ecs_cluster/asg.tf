resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = "ami-090fa75af13c156b4"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_service_role.name

  security_groups = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.main1.id, aws_subnet.main2.id]
  health_check_type = "ELB"
  health_check_grace_period = 300
  protect_from_scale_in = true
  target_group_arns = [aws_lb_target_group.lb-target-group.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ec2-sg" {
  name = "allow-all-ec2"
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