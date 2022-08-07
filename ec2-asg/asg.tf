resource "aws_launch_configuration" "asg-lc" {
  name          = "ec2-config"
  image_id      = "ami-090fa75af13c156b4"
  instance_type = "t2.micro"
  user_data = "${file("install_apache.sh")}"
  key_name = "ec2-keypair"

  security_groups = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true

}
resource "aws_autoscaling_group" "ec2-asg" {
    name = "ec2-asg"
    launch_configuration = aws_launch_configuration.asg-lc.name
    min_size = 2
    max_size = 4
    desired_capacity = 2
    vpc_zone_identifier = [aws_subnet.public_subnet-1.id, aws_subnet.public_subnet-2.id]
    health_check_type = "ELB"
    health_check_grace_period = 300
    protect_from_scale_in = true
    target_group_arns = [aws_lb_target_group.lb-target-group.arn]

}



resource "aws_security_group" "ec2-sg" {
  name   = "allow-all-ec2"
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