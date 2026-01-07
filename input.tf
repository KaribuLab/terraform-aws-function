variable "function_name" {
  type        = string
  description = "Name of lambda function"
}

variable "policy_name" {
  type        = string
  description = "Policy name"
  default     = null
}

variable "role_name" {
  type        = string
  description = "Role name"
  default     = null
}

variable "iam_policy" {
  type        = string
  description = "IAM policy"
}

variable "runtime" {
  type        = string
  description = "Runtime (required when package_type is Zip)"
  default     = null
}

variable "handler" {
  type        = string
  description = "Handler (required when package_type is Zip)"
  default     = null
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Memory size"
}

variable "timeout" {
  type        = number
  default     = 30
  description = "Timeout"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables"
}

variable "bucket" {
  type        = string
  description = "Bucket for lambda function (required when package_type is Zip)"
  default     = null
}

variable "file_location" {
  type        = string
  description = "File location (required when package_type is Zip)"
  default     = null
}

variable "zip_location" {
  type        = string
  description = "Zip location (required when package_type is Zip)"
  default     = null
}

variable "zip_name" {
  type        = string
  description = "Zip name (required when package_type is Zip)"
  default     = null
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags"
}

variable "event_sources_arn" {
  type        = list(string)
  default     = []
  description = "Event sources arn"
}

variable "batch_size" {
  type        = number
  default     = 1
  description = "Batch size"
}

variable "batch_window" {
  type        = number
  default     = 0
  description = "Batch window"
}

variable "max_concurrency" {
  type        = number
  default     = -1
  description = "Max concurrency"
}

variable "alias" {
  type        = string
  default     = null
  description = "Alias"
}

variable "provisioned_concurrency" {
  type        = number
  default     = 0
  description = "Provisioned concurrency"
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  description = "VPC configuration"
  default     = null
}

variable "publish" {
  type        = bool
  default     = false
  description = "Publish new version"
}

variable "function_url" {
  type        = object({
    authorization_type = string
    cors = object({
      allow_origins = list(string)
      allow_methods = list(string)
      allow_headers = list(string)
      expose_headers = list(string)
    })
  })
  default     = null
  description = "Function URL configuration"
}

variable "is_edge" {
  type        = bool
  default     = false
  description = "Is Lambda@Edge"

}

variable "package_type" {
  type        = string
  default     = "Zip"
  description = "Lambda deployment package type (Zip or Image)"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be either 'Zip' or 'Image'."
  }
}

variable "image_uri" {
  type        = string
  default     = null
  description = "ECR image URI (required when package_type is Image)"
}
