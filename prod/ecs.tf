resource "aws_ecs_cluster" "otel_service_cluster" {
  name = format("%s-cluster", var.app_name)
}

resource "aws_ecs_task_definition" "ecs_tasks" {
  family                   = format("%s-task", var.app_name)
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
      ],
      environment = [
        {
          name = "SERVICE_NAME",
          value = "service-entrypoint"
        },
        {
          name = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = format("collector:%s", var.collector_grpc_port)
        },
        {
          name = "ENDPOINT_SERVICE_A",
          value = "service-a:5000"
        },
        {
          name = "ENDPOINT_SERVICE_B",
          value = "service-b:5000"
        },
        {
          name = "TRACES_EXPORTER",
          value = "noop"
        },
        {
          name = "METRICS_EXPORTER",
          value = "noop"
        },
        {
          name = "LOGS_EXPORTER",
          value = "noop"
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
          containerPort = 5000
          hostPort = 5000
        }
      ],
      environment = [
        {
          name = "SERVICE_NAME",
          value = "service-a"
        },
        {
          name = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = format("collector:%s", var.collector_grpc_port)
        },
        {
          name = "ENDPOINT_SERVICE_B",
          value = "service-b:5000"
        },
        {
          name = "TRACES_EXPORTER",
          value = "noop"
        },
        {
          name = "METRICS_EXPORTER",
          value = "noop"
        },
        {
          name = "LOGS_EXPORTER",
          value = "noop"
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
          containerPort = 5000
          hostPort = 5000
        }
      ],
      environment = [
        {
          name = "SERVICE_NAME",
          value = "service-b"
        },
        {
          name = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = format("collector:%s", var.collector_grpc_port)
        },
        {
          name = "TRACES_EXPORTER",
          value = "noop"
        },
        {
          name = "METRICS_EXPORTER",
          value = "noop"
        },
        {
          name = "LOGS_EXPORTER",
          value = "noop"
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
      environment = [
        {
          name = "DATADOG_API_SITE",
          value = var.datadog_api_site
        },
        {
          name = "DATADOG_API_KEY",
          value = var.datadog_api_key
        }
      ]
      command = ["--config", "/etc/collector-config.yml"]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "service_entrypoint" {
  name            = "service-entrypoint"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.ecs_tasks.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_entrypoint.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_group.arn
    container_name   = "service-entrypoint"
    container_port   = 5000
  }
}

resource "aws_ecs_service" "service_a" {
  name            = "service-a"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.ecs_tasks.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_a.arn
  }
}

resource "aws_ecs_service" "service_b" {
  name            = "service-b"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.ecs_tasks.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_b.arn
  }
}

resource "aws_ecs_service" "collector" {
  name            = "collector"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.ecs_tasks.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.collector.arn
  }
}