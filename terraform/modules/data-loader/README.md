# Terraform IaC for Babylon Data Loader
 
This module provisions the serverless compute infrastructure for the Babylon Data Loader:
- **AWS Lambda Function**: ARM64 container runtime (`babylon-data-loader`) configured to ingest transactions into the datalake.
- **`lifecycle { ignore_changes = [image_uri] }`**: Ensures application deployments managed by `babylon_data_loader` are never overwritten by Terraform.
- **S3 Bucket Notification**: Triggers the Lambda function when CSV files are uploaded to `unprocessed/*.csv` or `unprocessed/*.CSV`.
- **Lambda Permission**: Grants `s3.amazonaws.com` permission to invoke the function.
- **CloudWatch Log Group**: `/aws/lambda/babylon-data-loader` with 14-day retention.
- **IAM Role**: Consumes the externally provisioned `babylon-data-loader-lambda-role` via data source.
