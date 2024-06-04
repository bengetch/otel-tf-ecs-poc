resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_one" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet_two" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-east-2b"
}

resource "aws_service_discovery_private_dns_namespace" "private_dns_namespace" {
  name        = format("%s-service-discovery-namespace", var.app_name)
  vpc         = aws_vpc.vpc.id
  description = "private DNS namespace"
}

resource "aws_service_discovery_service" "service_entrypoint" {
  name = "service-entrypoint"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}

resource "aws_service_discovery_service" "service_a" {
  name = "service-a"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}

resource "aws_service_discovery_service" "service_b" {
  name = "service-b"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}

resource "aws_service_discovery_service" "collector" {
  name = "collector"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    routing_policy = "MULTIVALUE"

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}