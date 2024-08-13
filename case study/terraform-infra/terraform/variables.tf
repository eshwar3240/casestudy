variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "lb_logs_bucket" {
  description = "Name of the S3 bucket for Load Balancer logs"
  type        = string
  default     = "eshwar2-lb-logs-bucket"
}
