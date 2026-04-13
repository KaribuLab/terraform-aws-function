terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "<= 6.35.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

module "lambda_test" {
    source = "../.."

    function_name = "test-lambda-validate"
    package_type  = "Zip"
    runtime       = "nodejs24.x"
    handler       = "index.handler"

    bucket        = var.bucket
    file_location = "${path.module}/src"
    zip_location  = "${path.module}/build"
    zip_name      = "lambda.zip"

    iam_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
                Resource = "arn:aws:logs:*:*:*"
            }
        ]
    })

    environment_variables = {
        ENV = "test"
    }

    common_tags = {
        Environment = "test"
        Project     = "terraform-aws-function"
    }
}