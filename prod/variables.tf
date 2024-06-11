variable "aws_region" {
  description = "aws region to use for deployed resources"
  type        = string
  default = "us-east-2"
}

variable "app_name" {
  description = "name of the application"
  type = string
  default = "otel-app"
}

variable "datadog_grpc_port" {
  description = "port on collector service to use for GRPC"
  type = number
  default = 4317
}

variable "datadog_api_site" {
  description = "url for datadog API"
  type = string
  default = "datadoghq.com"
}

variable "datadog_api_key" {
  description = "datadog api key"
  type = string
  default = ""
}