resource "aws_ecs_cluster" "otel_service_cluster" {
  name = format("%s-cluster", var.app_name)
}

resource "aws_ecs_task_definition" "task-entrypoint" {
  family = format("%s-entrypoint", var.app_name)
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1 GB"

  container_definitions = jsonencode([
    {
      name = "service-entrypoint"
      image = "bengetch/otel-poc-service:entrypoint-x86"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort = 5000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/service-entrypoint"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name = "SERVICE_NAME",
          value = "service-entrypoint"
        },
        {
          name = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = format("localhost:%s", tostring(var.datadog_grpc_port))
        },
        {
          name = "ENDPOINT_SERVICE_A",
          value = "service-a.otel-app-namespace:5000"
        },
        {
          name = "ENDPOINT_SERVICE_B",
          value = "service-b.otel-app-namespace:5000"
        },
        {
          name = "TRACES_EXPORTER",
          value = "otel"
        },
        {
          name = "METRICS_EXPORTER",
          value = "otel"
        },
        {
          name = "LOGS_EXPORTER",
          value = "stdout"
        },
        {
          name = "SELF_PORT",
          value = "5000"
        }
      ]
    },
    {
      name = "datadog"
      image = "datadog/agent:latest"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = var.datadog_grpc_port
          hostPort = var.datadog_grpc_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/service-entrypoint"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name = "DD_SITE",
          value = var.datadog_api_site
        },
        {
          name = "DD_API_KEY",
          value = var.datadog_api_key
        },
        {
          name = "ECS_FARGATE",
          value = "true"
        },
        {
          name = "DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT",
          value = format("localhost:%s", tostring(var.datadog_grpc_port))
        },
        {
          name = "DD_APM_ENABLED",
          value = "true"
        },
        {
          name = "DD_LOGS_ENABLED",
          value = "true"
        },
        {
          name = "DD_OTLP_CONFIG_LOGS_ENABLED",
          value = "true"
        },
        {
          name = "DD_HOSTNAME",
          value = "datadog"
        }
      ]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_task_definition" "task-service-a" {
  family = format("%s-service-a", var.app_name)
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1 GB"
  container_definitions = jsonencode([
    {
      name = "service-a"
      image = "bengetch/otel-poc-service:a-x86"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/service-a"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name = "SERVICE_NAME",
          value = "service-a"
        },
        {
          name = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = format("localhost:%s", tostring(var.datadog_grpc_port))
        },
        {
          name = "ENDPOINT_SERVICE_B",
          value = "service-b.otel-app-namespace:5000"
        },
        {
          name = "TRACES_EXPORTER",
          value = "otel"
        },
        {
          name = "METRICS_EXPORTER",
          value = "otel"
        },
        {
          name = "LOGS_EXPORTER",
          value = "otel"
        },
        {
          name = "SELF_PORT",
          value = "5000"
        }
      ]
    },
    {
      name = "datadog"
      image = "datadog/agent:latest"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = var.datadog_grpc_port
          hostPort = var.datadog_grpc_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/service-a"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name = "DD_SITE",
          value = var.datadog_api_site
        },
        {
          name = "DD_API_KEY",
          value = var.datadog_api_key
        },
        {
          name = "ECS_FARGATE",
          value = "true"
        },
        {
          name = "DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT",
          value = format("localhost:%s", tostring(var.datadog_grpc_port))
        },
        {
          name = "DD_APM_ENABLED",
          value = "true"
        },
        {
          name = "DD_LOGS_ENABLED",
          value = "true"
        },
        {
          name = "DD_OTLP_CONFIG_LOGS_ENABLED",
          value = "true"
        },
        {
          name = "DD_HOSTNAME",
          value = "datadog"
        }
      ]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_task_definition" "task-service-b" {
  family = format("%s-service-b", var.app_name)
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1 GB"
  container_definitions = jsonencode([
    {
      name = "service-b"
      image = "bengetch/otel-poc-service:b-x86"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/service-b"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name = "SERVICE_NAME",
          value = "service-b"
        },
        {
          name = "OTEL_EXPORTER_OTLP_ENDPOINT",
          value = format("localhost:%s", tostring(var.datadog_grpc_port))
        },
        {
          name = "TRACES_EXPORTER",
          value = "otel"
        },
        {
          name = "METRICS_EXPORTER",
          value = "otel"
        },
        {
          name = "LOGS_EXPORTER",
          value = "otel"
        },
        {
          name = "SELF_PORT",
          value = "5000"
        }
      ]
    },
    {
      name = "datadog"
      image = "datadog/agent:latest"
      cpu = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = var.datadog_grpc_port
          hostPort = var.datadog_grpc_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/service-b"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name = "DD_SITE",
          value = var.datadog_api_site
        },
        {
          name = "DD_API_KEY",
          value = var.datadog_api_key
        },
        {
          name = "ECS_FARGATE",
          value = "true"
        },
        {
          name = "DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT",
          value = format("localhost:%s", tostring(var.datadog_grpc_port))
        },
        {
          name = "DD_APM_ENABLED",
          value = "true"
        },
        {
          name = "DD_LOGS_ENABLED",
          value = "true"
        },
        {
          name = "DD_OTLP_CONFIG_LOGS_ENABLED",
          value = "true"
        },
        {
          name = "DD_HOSTNAME",
          value = "datadog"
        }
      ]
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "service_entrypoint" {
  name            = "service-entrypoint"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.task-entrypoint.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_entrypoint.arn
  }
}

resource "aws_ecs_service" "service_a" {
  name            = "service-a"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.task-service-a.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private.id]
    security_groups = [aws_security_group.ecs.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_a.arn
  }
}

resource "aws_ecs_service" "service_b" {
  name            = "service-b"
  cluster         = aws_ecs_cluster.otel_service_cluster.id
  task_definition = aws_ecs_task_definition.task-service-b.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private.id]
    security_groups = [aws_security_group.ecs.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_b.arn
  }
}
