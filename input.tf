variable function_name {
  type = string
  description = "Name of lambda function"
}

variable iam_policy {
    type = string
    description = "IAM policy"
}

variable runtime {
    type = string
    description = "Runtime"
}

variable handler {
    type = string
    description = "Handler"

}

variable memory_size {
    type = number
    default = 128
    description = "Memory size"
}

variable timeout {
    type = number
    default = 30
    description = "Timeout"
}

variable environment_variables {
    type = map(string)
    description = "Environment variables"
}

variable bucket {
    type = string
    description = "Bucket for lambda function"
}

variable file_location {
    type = string
    description = "File location"
}

variable zip_location {
    type = string
    description = "Zip location"
}

variable zip_name {
    type = string
    description = "Zip name"
}

variable common_tags {
    type = map(string)
    description = "Common tags"
}

variable event_sources_arn {
    type = list(string)
    default = []
    description = "Event sources arn"
}

variable batch_size {
    type = number
    default = 1
    description = "Batch size"
}

variable batch_window {
    type = number
    default = 0
    description = "Batch window"
}

variable max_concurrency {
    type = number
    default = -1
    description = "Max concurrency"
}