# ==============================================================================
# Datalake Storage & Database Credentials Module
# ==============================================================================

data "aws_caller_identity" "current" {}

locals {
  resolved_bucket_name = var.bucket_name != "" ? var.bucket_name : "babylon-datalake-landing-${data.aws_caller_identity.current.account_id}"
}

# ==============================================================================
# Amazon S3 Landing Bucket for Raw & Processed Statements
# ==============================================================================

resource "aws_s3_bucket" "landing" {
  bucket = local.resolved_bucket_name

  tags = merge(
    var.tags,
    {
      Name = local.resolved_bucket_name
    }
  )
}

# Server-Side Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "landing" {
  bucket = aws_s3_bucket.landing.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "landing" {
  bucket = aws_s3_bucket.landing.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce in-transit encryption (TLS 1.2+)
resource "aws_s3_bucket_policy" "landing_tls" {
  bucket = aws_s3_bucket.landing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.landing.arn,
          "${aws_s3_bucket.landing.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Lifecycle management for archived files
resource "aws_s3_bucket_lifecycle_configuration" "landing" {
  bucket = aws_s3_bucket.landing.id

  rule {
    id     = "archive-processed-statements"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }
  }
}

# ==============================================================================
# AWS Secrets Manager Secret for MongoDB Datalake Credentials
# ==============================================================================

resource "aws_secretsmanager_secret" "datalake_credentials" {
  name                    = var.secret_name
  description             = "MongoDB Atlas datalake credentials for Babylon services"
  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "datalake_credentials" {
  secret_id = aws_secretsmanager_secret.datalake_credentials.id
  secret_string = jsonencode({
    engine      = "mongodb"
    host        = "cluster0.xxxxx.mongodb.net"
    port        = "27017"
    username    = "babylon_app"
    password    = "change-me-in-vault"
    database    = "babylon_datalake"
    auth_source = "admin"
    mongo_uri   = ""
  })

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}
