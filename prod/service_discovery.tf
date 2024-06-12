resource "aws_service_discovery_private_dns_namespace" "private_dns_namespace" {
  name        = "otel-app-namespace"
  vpc         = aws_vpc.vpc.id
  description = "private DNS namespace"
}

resource "aws_service_discovery_service" "service_entrypoint" {
  name = "service-entrypoint"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "service_a" {
  name = "service-a"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "service_b" {
  name = "service-b"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}