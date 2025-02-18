# Terraform AWS Function

This module creates a straightforward Lambda function triggered by an event source.

## Inputs

| Name                      | Type         | Description                                                       | Required |
| ------------------------- | ------------ | ----------------------------------------------------------------- | -------- |
| function_name             | string       | Name of lambda function                                           | yes      |
| role_name                 | string       | Lambda function role name                                         | no       |
| policy_name               | string       | Lambda function policy name                                       | no       |
| iam_policy                | string       | JSON IAM policy                                                   | yes      |
| runtime                   | string       | Runtime for lambda function                                       | yes      |
| handler                   | string       | Handler for lambda function                                       | yes      |
| memory_size               | number       | Memory size for lambda function **(default: 128)**                | no       |
| timeout                   | number       | Timeout seconds for lambda function **(default: 30)**             | no       |
| environment_variables     | map(string)  | Environment variables for lambda function                         | yes      |
| bucket                    | string       | Name of bucket where de packaged lambda function will be uploaded | yes      |
| file_location             | string       | Local path to the packaged lambda function                        | yes      |
| zip_location              | string       | Local path to the generated zip lambda function                   | yes      |
| zip_name                  | string       | Name of the zip file                                              | yes      |
| batch_size                | number       | Event source batch size **(default: 1)**                          | no       |
| batch_window              | number       | Event source batch window **(default: 0)**                        | no       |
| max_concurrency           | number       | Reserved concurrent executions                                    | no       |
| provisioned_concurrency   | number       | Provisioned concurrency                                           | no       |
| common_tags               | map(string)  | Common tags for components                                        | yes      |
| event_sources_arn         | list(string) | Event source ARN list **(default: [])**                           | no       |
| publish                   | bool         | Publish a new version                                             | no       |
| [vpc_config](#vpc_config) | object()     | VPC Configuration **(default: null)**                             | no       |

### vpc_config

| Name               | Type         | Description        |
| ------------------ | ------------ | ------------------ |
| subnet_ids         | list(string) | Subnets IDs        | yes |
| security_group_ids | list(string) | Security Group IDs | yes |

## Outputs

| Name          | Type   | Description          |
| ------------- | ------ | -------------------- |
| function_name | string | Lambda function name |
| invoke_arn    | string | Function invoke ARN  |
| lambda_arn    | string | Function ARN         |