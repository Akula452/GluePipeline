# Development environment configuration
# This file contains variable values for the development environment

# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "gluepipeline"
environment  = "dev"

# Common Tags
common_tags = {
  Project     = "GluePipeline"
  ManagedBy   = "Terraform"
  Environment = "dev"
  Owner       = "DataEngineering"
}

# Glue Job Configuration
glue_version        = "4.0"
worker_type         = "G.1X"
number_of_workers   = 2
job_timeout         = 2880
max_concurrent_runs = 1
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
# These values should be customized for your dev environment
jdbc_connection_url = "jdbc:postgresql://dev-db-endpoint.region.rds.amazonaws.com:5432/devdb"
db_username         = "dev-db-username"
# db_password should be set via environment variable or secrets manager
# export TF_VAR_db_password="your-dev-password"

# Network Configuration for Glue Connection (Optional - for VPC connectivity)
# Uncomment and configure if your database is in a VPC
# availability_zone  = "us-east-1a"
# security_group_ids = ["sg-xxxxxxxxx"]
# subnet_id          = "subnet-xxxxxxxxx"

# Scheduling Configuration
enable_schedule = false
job_schedule    = "cron(0 12 * * ? *)" # Daily at 12:00 UTC
trigger_enabled = true

# CloudWatch Configuration
log_retention_days = 7
