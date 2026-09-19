variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "AWS VPC ID for Babylon infrastructure"
  type        = string
  default     = "vpc-0c2611c0821789bca"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas Programmatic API Public Key"
  type        = string
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas Programmatic API Private Key"
  type        = string
  sensitive   = true
}

variable "mongodbatlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "atlas_region" {
  description = "MongoDB Atlas region (AWS provider region format, e.g. US_EAST_1)"
  type        = string
  default     = "US_EAST_1"
}
