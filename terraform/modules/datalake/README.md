# Terraform IaC for Babylon Datalake
 
This module provisions the datalake landing storage and secret store for Babylon services:
- **S3 Landing Bucket**: Dedicated encrypted storage for incoming statement CSVs (`unprocessed/`) and processed archives (`processed/`).
- **Bucket Security**: Public access blocked, SSE-S3 AES-256 server-side encryption enforced, and TLS 1.2+ mandatory transport policy.
- **Lifecycle Policy**: Automatically transitions `processed/` objects to Standard-IA after 30 days and permanently expires them after 90 days.
- **Secrets Manager**: Stores datalake connection strings and database credentials (`babylon/datalake/credentials`).
