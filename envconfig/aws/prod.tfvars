# Production environment configuration
# This file contains variable values for the production environment

# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "gluepipeline"
environment  = "prod"

# Common Tags
common_tags = {
  Project     = "GluePipeline"
  ManagedBy   = "Terraform"
  Environment = "prod"
  Owner       = "DataEngineering"
}

# Glue Job Configuration
glue_version        = "4.0"
worker_type         = "G.2X"  # Larger workers for production
number_of_workers   = 5       # More workers for production workload
job_timeout         = 2880
max_concurrent_runs = 3       # Allow more concurrent runs in production
job_command_name    = "glueetl"
python_version      = "3"
script_location     = "scripts/etl_job.py"
job_bookmark_option = "job-bookmark-enable"

# Additional job arguments (optional)
additional_job_arguments = {
  # "--extra-py-files" = "s3://bucket/dependencies.zip"
  # "--extra-jars"     = "s3://bucket/jars/mysql-connector.jar"
}

# SQL Connection Configuration
# These values should be customized for your production environment
jdbc_connection_url = "jdbc:postgresql://prod-db-endpoint.region.rds.amazonaws.com:5432/proddb"
db_username         = "prod-db-username"
# db_password should be set via environment variable or secrets manager
# export TF_VAR_db_password="your-prod-password"

# Network Configuration for Glue Connection (Required for production VPC)
# Uncomment and configure for your production VPC
# availability_zone  = "us-east-1a"
# security_group_ids = ["sg-xxxxxxxxx"]
# subnet_id          = "subnet-xxxxxxxxx"

# Scheduling Configuration
enable_schedule = true  # Enable scheduling in production
job_schedule    = "cron(0 2 * * ? *)"  # Daily at 2:00 AM UTC
trigger_enabled = true

# CloudWatch Configuration
log_retention_days = 30  # Longer retention for production
