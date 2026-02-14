# Production Environment Configuration
# This file contains environment-specific variables for the production environment

# AWS Configuration
aws_region = "us-east-1"
# AWS Account ID for production environment
# IMPORTANT: Replace with your actual AWS Account ID before deployment
aws_account_id = "000000000000"

# Project Configuration
project_name = "gluepipeline"
environment  = "prod"

# Common Tags
common_tags = {
  Project     = "GluePipeline"
  ManagedBy   = "Terraform"
  Environment = "prod"
  Owner       = "DataEngineering"
  CostCenter  = "Production"
}

# Glue Job Configuration
glue_version        = "4.0"
worker_type         = "G.2X"
number_of_workers   = 5
job_timeout         = 2880
max_concurrent_runs = 3
job_command_name    = "glueetl"
python_version      = "3"
script_location     = "scripts/etl_job.py"
job_bookmark_option = "job-bookmark-enable"

# Additional job arguments (optional)
additional_job_arguments = {
  "--enable-auto-scaling" = "true"
  "--enable-metrics"      = "true"
}

# SQL Connection Configuration
# Note: Use AWS Secrets Manager for production credentials
jdbc_connection_url = "jdbc:postgresql://prod-db.us-east-1.rds.amazonaws.com:5432/proddb"
db_username         = "prod_user"
# db_password should be set via environment variable or AWS Secrets Manager:
# export TF_VAR_db_password="your-secure-prod-password"

# Network Configuration for Glue Connection (Required for production VPC)
# Uncomment and configure with actual production values
# availability_zone  = "us-east-1a"
# security_group_ids = ["sg-prod123456"]
# subnet_id          = "subnet-prod123456"

# Scheduling Configuration
enable_schedule = true
job_schedule    = "cron(0 2 * * ? *)"  # Daily at 2:00 AM UTC
trigger_enabled = true

# CloudWatch Configuration
log_retention_days = 30
