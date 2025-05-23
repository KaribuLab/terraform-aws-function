locals {
  iam_role_name     = var.role_name != null ? var.role_name : "${var.function_name}-execution-role"
  iam_policy_name   = var.policy_name != null ? var.policy_name : "${var.function_name}-execution-policy"
  zip_name_location = "${var.zip_location}/${var.zip_name}"
  iam_policy_map    = jsondecode(var.iam_policy)
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
          Service = var.is_edge ? ["lambda.amazonaws.com", "edgelambda.amazonaws.com"] : ["lambda.amazonaws.com"]
        }
      }
    ]
  })
  tags = var.common_tags
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role_policy" "function" {
  name = local.iam_policy_name
  role = aws_iam_role.function.id
  policy = var.vpc_config == null ? var.iam_policy : jsonencode({
    Version = local.iam_policy_map.Version
    Statement = concat(local.iam_policy_map.Statement, [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSubnets",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = [
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:vpc/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
      }
    ])
  })
}

data "archive_file" "function" {
  type        = "zip"
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
  etag   = filemd5(data.archive_file.function.output_path)
}

resource "aws_lambda_function" "function" {
  function_name                  = var.function_name
  role                           = aws_iam_role.function.arn
  s3_bucket                      = data.aws_s3_bucket.function.id
  s3_key                         = aws_s3_object.function.key
  source_code_hash               = data.archive_file.function.output_base64sha256
  runtime                        = var.runtime
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.max_concurrency
  timeout                        = var.timeout
  publish                        = var.publish || var.provisioned_concurrency > 0

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }

  }
  environment {
    variables = var.environment_variables
  }
  tags = var.common_tags
}

resource "aws_lambda_function_url" "function" {
  count              = var.function_url != null ? 1 : 0
  function_name      = aws_lambda_function.function.function_name
  authorization_type = var.function_url.authorization_type
  cors {
    allow_origins  = var.function_url.cors.allow_origins
    allow_methods  = var.function_url.cors.allow_methods
    allow_headers  = var.function_url.cors.allow_headers
    expose_headers = var.function_url.cors.expose_headers
  }
}

resource "aws_lambda_permission" "function" {
  count                  = var.function_url != null ? 1 : 0
  function_name          = aws_lambda_function.function.function_name
  action                 = "lambda:InvokeFunctionUrl"
  principal              = "lambda.amazonaws.com"
  function_url_auth_type = var.function_url.authorization_type
}

resource "aws_lambda_alias" "function" {
  count            = var.alias != null ? 1 : 0
  name             = var.alias
  function_name    = aws_lambda_function.function.arn
  function_version = aws_lambda_function.function.version

}

resource "aws_lambda_provisioned_concurrency_config" "function" {
  count                             = var.provisioned_concurrency > 0 ? 1 : 0
  function_name                     = var.alias != null ? aws_lambda_alias.function[count.index].function_name : aws_lambda_function.function.arn
  provisioned_concurrent_executions = var.provisioned_concurrency
  qualifier                         = var.alias != null ? aws_lambda_alias.function[count.index].name : aws_lambda_function.function.version
}

resource "aws_lambda_event_source_mapping" "function" {
  count                              = length(var.event_sources_arn)
  event_source_arn                   = var.event_sources_arn[count.index]
  enabled                            = true
  function_name                      = aws_lambda_function.function.arn
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.batch_window
}
