variable "aws_region" {
  description = "AWS region for datalake resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 landing bucket for raw transaction CSV statements"
  type        = string
  default     = ""
}

variable "secret_name" {
  description = "Name of the AWS Secrets Manager secret for MongoDB datalake credentials"
  type        = string
  default     = "babylon/datalake/credentials"
}

variable "tags" {
  description = "Tags to attach to datalake resources"
  type        = map(string)
  default = {
    Project   = "babylon"
    Component = "datalake"
    ManagedBy = "terraform"
  }
}
