// Required
variable "function_name" {
  description = "A unique name for your lambda fn"
  type        = string
}
// Optional
variable "localstack_url" {
  description = "Localstack endpoint for all services"
  type        = string
  default     = "http://localhost:4566"
}
variable "description" {
  description = "Description of what your lambda function does"
  default     = ""
}
variable "runtime" {
  description = "The runtime env for the lambda fn you're uploading"
  type        = string
  default     = "go1.x"
}
variable "timeout" {
  description = "The amount of time your lambda fn has to run in seconds. Defaults to 3"
  type = number
  default     = 3
}
variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type = number
  default     = 128
}
variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function"
  type        = number
  default     = -1
}
variable "environment_variables" {
  description = "A map that defines the environment variables for the lambda function"
  type        = map(string)
  default     = {}
}
