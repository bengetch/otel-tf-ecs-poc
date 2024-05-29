resource "aws_ecs_cluster" "otel_service_cluster" {
  name = format("%s-cluster", var.app_name)
}

resource "aws_ecs_task_definition" "ecs_tasks" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name = "service-entrypoint"
      image = "bengetch/otel-poc-service:entrypoint"
      cpu = 128
      memory = 128
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort = 5000
        }
      ]
    },
    {
      name = "service-a"
      image = "bengetch/otel-poc-service:a"
      cpu = 128
      memory = 128
      essential = true
      portMappings = [
        {
          containerPort = 5001
          hostPort = 5001
        }
      ]
    },
    {
      name = "service-b"
      image = "bengetch/otel-poc-service:b"
      cpu = 128
      memory = 128
      essential = true
      portMappings = [
        {
          containerPort = 5002
          hostPort = 5002
        }
      ]
    },
    {
      name = "collector"
      image = "bengetch/otel-poc-service:collector"
      cpu = 128
      memory = 128
      essential = true
      portMappings = [
        {
          containerPort = 4317
          hostPort = 4317
        },
        {
          containerPort = 4318
          hostPort = 4318
        }
      ],
      command = ["--config", "/etc/collector-config.yml"]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_role.arn
  task_role_arn      = aws_iam_role.ecs_role.arn
}