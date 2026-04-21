# Terraform AWS Function

This module creates a straightforward Lambda function triggered by an event source.

Supports both deployment types:
- **Zip package**: Deploy Lambda function from a ZIP file uploaded to S3
- **Docker Image**: Deploy Lambda function from a container image in ECR

**Execution role:** By default the module creates an IAM role and attaches the inline policy from `iam_policy`. Set **`lambda_role_arn`** to the ARN of an existing role to skip role and policy creation; the Lambda still uses that role, but you must grant all required permissions on that role outside this module.

## Inputs

| Name                      | Type         | Description                                                       | Required |
| ------------------------- | ------------ | ----------------------------------------------------------------- | -------- |
| function_name             | string       | Name of lambda function                                           | yes      |
| lambda_role_arn           | string       | Existing Lambda execution role ARN (if set, module does not create IAM role or policy) | no       |
| role_name                 | string       | Lambda function role name                                         | no       |
| policy_name               | string       | Lambda function policy name                                       | no       |
| iam_policy                | string       | JSON IAM policy (used only when `lambda_role_arn` is not set)     | no¹      |
| package_type              | string       | Lambda deployment package type: Zip or Image **(default: Zip)**   | no       |
| runtime                   | string       | Runtime for lambda function (required when package_type is Zip)   | conditional |
| handler                   | string       | Handler for lambda function (required when package_type is Zip)   | conditional |
| image_uri                 | string       | ECR image URI (required when package_type is Image)               | conditional |
| memory_size               | number       | Memory size for lambda function **(default: 128)**                | no       |
| timeout                   | number       | Timeout seconds for lambda function **(default: 30)**             | no       |
| environment_variables     | map(string)  | Environment variables for lambda function                         | yes      |
| bucket                    | string       | Name of bucket (required when package_type is Zip)                | conditional |
| file_location             | string       | Local path to source files (required when package_type is Zip)    | conditional |
| zip_location              | string       | Local path to generated zip (required when package_type is Zip)   | conditional |
| zip_name                  | string       | Name of the zip file (required when package_type is Zip)          | conditional |
| batch_size                | number       | Event source batch size **(default: 1)**                          | no       |
| batch_window              | number       | Event source batch window **(default: 0)**                        | no       |
| max_concurrency           | number       | Reserved concurrent executions **(default: -1)**                  | no       |
| provisioned_concurrency   | number       | Provisioned concurrency **(default: 0)**                          | no       |
| alias                     | string       | Function alias                                                    | no       |
| common_tags               | map(string)  | Common tags for components                                        | yes      |
| event_sources_arn         | list(string) | Event source ARN list **(default: [])**                           | no       |
| publish                   | bool         | Publish a new version **(default: false)**                        | no       |
| architectures             | list(string) | Instruction set architectures **(default: ["x86_64"])**           | no       |
| [vpc_config](#vpc_config) | object()     | VPC Configuration **(default: null)**                             | no       |
| function_url              | object()     | Function URL configuration **(default: null)**                    | no       |
| is_edge                   | bool         | Is Lambda@Edge **(default: false)**                               | no       |

¹ When the module creates the execution role (`lambda_role_arn` omitted), provide a policy that allows logging and any other actions your function needs. When using `lambda_role_arn`, inline policy in this module is not attached; configure the external role elsewhere.

### vpc_config

| Name               | Type         | Description        | Required |
| ------------------ | ------------ | ------------------ | -------- |
| subnet_ids         | list(string) | Subnets IDs        | yes      |
| security_group_ids | list(string) | Security Group IDs | yes      |

### function_url

| Name               | Type         | Description        | Required |
| ------------------ | ------------ | ------------------ | -------- |
| authorization_type | string       | Authorization type | yes      |
| cors               | object       | CORS configuration | yes      |

#### cors

| Name           | Type         | Description                 | Required |
| -------------- | ------------ | --------------------------- | -------- |
| allow_origins  | list(string) | Allowed origins             | yes      |
| allow_methods  | list(string) | Allowed HTTP methods        | yes      |
| allow_headers  | list(string) | Allowed headers             | yes      |
| expose_headers | list(string) | Headers exposed in response | yes      |

## Outputs

| Name           | Type           | Description |
| -------------- | -------------- | ----------- |
| role_name      | string \| null | IAM role name created by this module; `null` when `lambda_role_arn` is set |
| role_id        | string \| null | IAM role unique ID when the module creates the role; `null` when `lambda_role_arn` is set |
| role_arn       | string         | Effective execution role ARN (module-created role or value of `lambda_role_arn`) |
| function_name  | string         | Function name |
| function_url   | string \| null | Function URL when `function_url` is configured; otherwise `null` |
| invoke_arn     | string         | Function invoke ARN |
| lambda_arn     | string         | Function ARN |
| lambda_version | string         | Function version |

## Usage Examples

### Example 1: Lambda with Zip Package (Default)

```hcl
module "lambda_zip" {
  source = "git::https://github.com/KaribuLab/terraform-aws-function.git?ref=v0.8.0"

  function_name = "my-lambda-function"
  runtime       = "nodejs20.x"
  handler       = "index.handler"

  bucket        = "my-deployment-bucket"
  file_location = "${path.module}/src"
  zip_location  = "${path.module}/dist"
  zip_name      = "lambda.zip"

  iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  environment_variables = {
    ENV = "production"
  }

  timeout     = 30
  memory_size = 512

  common_tags = {
    Environment = "prod"
    Project     = "my-project"
  }
}
```

### Example 2: Lambda with an existing IAM execution role

When `lambda_role_arn` is set, the module does not create `aws_iam_role` or `aws_iam_role_policy`. Ensure the external role trusts `lambda.amazonaws.com` and has all permissions your code needs. Use output **`role_arn`** for the effective execution role ARN in both modes; **`role_id`** and **`role_name`** are only set when the module creates the role.

```hcl
module "lambda_existing_role" {
  source = "git::https://github.com/KaribuLab/terraform-aws-function.git?ref=v0.8.0"

  function_name     = "my-lambda-with-existing-role"
  lambda_role_arn   = "arn:aws:iam::123456789012:role/my-lambda-execution-role"
  runtime           = "nodejs20.x"
  handler           = "index.handler"

  bucket        = "my-deployment-bucket"
  file_location = "${path.module}/src"
  zip_location  = "${path.module}/dist"
  zip_name      = "lambda.zip"

  # iam_policy is not attached when lambda_role_arn is set (module default is fine)

  environment_variables = { ENV = "production" }
  common_tags = { Environment = "prod" }
}
```

### Example 3: Lambda with Docker Image

```hcl
module "lambda_image" {
  source = "git::https://github.com/KaribuLab/terraform-aws-function.git?ref=v0.8.0"

  function_name = "my-lambda-container"
  package_type  = "Image"
  image_uri     = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-lambda:latest"

  iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = "arn:aws:s3:::my-bucket/*"
      },
      {
        Effect = "Allow"
        Action = ["batch:SubmitJob"]
        Resource = ["arn:aws:batch:*:*:job-queue/*", "arn:aws:batch:*:*:job-definition/*"]
      }
    ]
  })

  environment_variables = {
    S3_BUCKET_NAME = "my-bucket"
    AWS_REGION     = "us-west-2"
  }

  timeout     = 60
  memory_size = 1024

  common_tags = {
    Environment = "prod"
    Project     = "my-project"
  }
}
```