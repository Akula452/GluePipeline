# Variables for AWS Glue Infrastructure

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID where resources will be created (must be provided via tfvars file)"
  type        = string
  default     = ""
  
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be a 12-digit number. Please provide it via the tfvars file."
  }
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "gluepipeline"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project     = "GluePipeline"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

# Glue Job Configuration
variable "glue_version" {
  description = "Glue version to use for the job"
  type        = string
  default     = "4.0"
}

variable "worker_type" {
  description = "Type of predefined worker that is allocated when a job runs"
  type        = string
  default     = "G.1X"
  
  validation {
    condition     = contains(["Standard", "G.1X", "G.2X", "G.025X", "G.4X", "G.8X", "Z.2X"], var.worker_type)
    error_message = "Worker type must be one of: Standard, G.1X, G.2X, G.025X, G.4X, G.8X, Z.2X."
  }
}

variable "number_of_workers" {
  description = "Number of workers allocated when a job runs"
  type        = number
  default     = 2
}

variable "job_timeout" {
  description = "Job timeout in minutes"
  type        = number
  default     = 2880
}

variable "max_concurrent_runs" {
  description = "Maximum number of concurrent runs allowed for the job"
  type        = number
  default     = 1
}

variable "job_command_name" {
  description = "Name of the job command (glueetl, pythonshell, gluestreaming)"
  type        = string
  default     = "glueetl"
}

variable "python_version" {
  description = "Python version for the Glue job"
  type        = string
  default     = "3"
}

variable "script_location" {
  description = "Location of the ETL script in S3 (relative to scripts bucket)"
  type        = string
  default     = "scripts/etl_job.py"
}

variable "job_bookmark_option" {
  description = "Job bookmark option (job-bookmark-enable, job-bookmark-disable, job-bookmark-pause)"
  type        = string
  default     = "job-bookmark-enable"
}

variable "additional_job_arguments" {
  description = "Additional arguments to pass to the Glue job"
  type        = map(string)
  default     = {}
}

# SQL Connection Configuration
variable "jdbc_connection_url" {
  description = "JDBC connection URL for the database (e.g., jdbc:postgresql://host:5432/db)"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "availability_zone" {
  description = "Availability zone for the Glue connection (must be in the same region as aws_region)"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs for the Glue connection (required for database connections)"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "Subnet ID for the Glue connection (required for database connections)"
  type        = string
  default     = null
}

# Scheduling Configuration
variable "enable_schedule" {
  description = "Enable scheduled trigger for the Glue job"
  type        = bool
  default     = false
}

variable "job_schedule" {
  description = "Cron expression for job schedule (e.g., cron(0 12 * * ? *))"
  type        = string
  default     = "cron(0 12 * * ? *)"
}

variable "trigger_enabled" {
  description = "Enable or disable the trigger"
  type        = bool
  default     = true
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}
