terraform {
  backend "s3" {}
}

locals {
  iam_role_name = "${var.function_name}-execution-role"
  iam_policy_name = "${var.function_name}-policy"
  zip_name_location = "${var.zip_location}/${var.zip_name}"
}

resource "aws_iam_role" "function" {
  name = local.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "function" {
  name = local.iam_policy_name
  role = aws_iam_role.function.id
  policy = var.iam_policy
}

data "archive_file" "function" {
  type = "zip"
  source_dir  = var.file_location
  output_path = local.zip_name_location
}

data "aws_s3_bucket" "function" {
  bucket = var.bucket
}

resource "aws_s3_object" "function" {
  bucket = data.aws_s3_bucket.function.id
  key    = "${var.function_name}/${var.zip_name}"
  source = data.archive_file.function.output_path
  etag = filemd5(data.archive_file.function.output_path)
}

resource "aws_lambda_function" "function" {
  function_name = "${var.function_name}"
  role = aws_iam_role.function.arn
  s3_bucket = data.aws_s3_bucket.function.id
  s3_key    = aws_s3_object.function.key
  source_code_hash = data.archive_file.function.output_base64sha256
  runtime = var.runtime
  handler = var.handler
  memory_size = var.memory_size
  reserved_concurrent_executions = var.max_concurrency
  timeout = var.timeout
  environment {
    variables = var.environment_variables
  }
  tags = var.common_tags
}

resource "aws_lambda_event_source_mapping" "function" {
    count = length(var.event_sources_arn)
    event_source_arn = var.event_sources_arn[count.index]
    enabled = true
    function_name = aws_lambda_function.function.arn
    batch_size = var.batch_size
    maximum_batching_window_in_seconds = var.batch_window
}