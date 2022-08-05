resource "aws_ecs_cluster" "apache-cluster" {
  name = "apache-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "example" {
  name = "example"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.bar.arn
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "apache-task"
  container_definitions = jsonencode([
    {
      name = "apache-container"
      image = "${aws_ecr_repository.apache.repository_url}:latest"
      memory = 512
      cpu = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])
  network_mode = "bridge"
  execution_role_arn = aws_iam_role.ecs-instance-role.arn
  task_role_arn = aws_iam_role.ecs-instance-role.arn
}

resource "aws_ecs_service" "apache-service" {
  name = "web-service"
  cluster =  aws_ecs_cluster.apache-cluster.id
  task_definition = aws_ecs_task_definition.aws-ecs-task.arn
  desired_count = 10
  ordered_placement_strategy {
    type = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb-target-group.arn
    container_name = "apache-container"
    container_port = 80
  }
  launch_type = "EC2"
  depends_on = [aws_lb_listener.ecs-listner]
}