variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "AWS VPC ID for Babylon infrastructure"
  type        = string
  default     = "vpc-0c2611c0821789bca"
}



variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas Programmatic API Public Key"
  type        = string
  default     = ""
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas Programmatic API Private Key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongodbatlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
  default     = ""
}

variable "atlas_region" {
  description = "MongoDB Atlas region (AWS provider region format, e.g. US_WEST_2)"
  type        = string
  default     = "US_WEST_2"
}
