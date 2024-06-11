

resource "aws_cloudwatch_log_group" "log_group_entrypoint" {
  name              = "/ecs/service-entrypoint"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "log_group_a" {
  name              = "/ecs/service-a"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "log_group_b" {
  name              = "/ecs/service-b"
  retention_in_days = 30
}