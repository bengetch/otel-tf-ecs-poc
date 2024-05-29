resource "aws_s3_bucket" "otel_config_bucket" {
  bucket = format("%s-config-bucket")
}

resource "aws_s3_bucket_object" "otel_collector_file" {
  bucket = aws_s3_bucket.otel_config_bucket.bucket
  key = "collector-config.yml"
  source = "./cfg/collector-config.yml"
}