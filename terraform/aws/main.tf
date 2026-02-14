# Terraform configuration for AWS Glue Job with SQL Connection
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Glue Scripts
resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.project_name}-glue-scripts-${var.environment}"
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-glue-scripts"
    }
  )
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "glue_scripts_versioning" {
  bucket = aws_s3_bucket.glue_scripts.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket for Glue temporary files
resource "aws_s3_bucket" "glue_temp" {
  bucket = "${var.project_name}-glue-temp-${var.environment}"
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-glue-temp"
    }
  )
}

# IAM Role for Glue Job
resource "aws_iam_role" "glue_role" {
  name               = "${var.project_name}-glue-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-glue-role"
    }
  )
}

# Attach AWS Managed Policy for Glue Service Role
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# IAM Policy for S3 Access
resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "${var.project_name}-glue-s3-policy-${var.environment}"
  role = aws_iam_role.glue_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.glue_scripts.arn,
          "${aws_s3_bucket.glue_scripts.arn}/*",
          aws_s3_bucket.glue_temp.arn,
          "${aws_s3_bucket.glue_temp.arn}/*"
        ]
      }
    ]
  })
}

# Glue Connection for SQL Database
resource "aws_glue_connection" "sql_connection" {
  name = "${var.project_name}-sql-connection-${var.environment}"
  
  connection_properties = {
    JDBC_CONNECTION_URL = var.jdbc_connection_url
    USERNAME            = var.db_username
    PASSWORD            = var.db_password
  }
  
  connection_type = "JDBC"
  
  dynamic "physical_connection_requirements" {
    for_each = var.subnet_id != null && length(var.security_group_ids) > 0 ? [1] : []
    content {
      availability_zone      = var.availability_zone
      security_group_id_list = var.security_group_ids
      subnet_id              = var.subnet_id
    }
  }
  
  description = "SQL database connection for Glue jobs"
}

# Glue Catalog Database
resource "aws_glue_catalog_database" "glue_database" {
  name        = "${var.project_name}_database_${var.environment}"
  description = "Glue catalog database for ${var.project_name}"
  
  create_table_default_permission {
    permissions = ["ALL"]
    
    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

# Glue Job with SQL Connection
resource "aws_glue_job" "etl_job" {
  name              = "${var.project_name}-etl-job-${var.environment}"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  timeout           = var.job_timeout
  
  command {
    name            = var.job_command_name
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/${var.script_location}"
    python_version  = var.python_version
  }
  
  connections = [aws_glue_connection.sql_connection.name]
  
  default_arguments = merge(
    {
      "--TempDir"                          = "s3://${aws_s3_bucket.glue_temp.bucket}/temp/"
      "--enable-metrics"                   = "true"
      "--enable-spark-ui"                  = "true"
      "--spark-event-logs-path"           = "s3://${aws_s3_bucket.glue_temp.bucket}/spark-logs/"
      "--enable-job-insights"             = "true"
      "--enable-glue-datacatalog"         = "true"
      "--job-language"                    = "python"
      "--job-bookmark-option"             = var.job_bookmark_option
      "--enable-continuous-cloudwatch-log" = "true"
    },
    var.additional_job_arguments
  )
  
  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-etl-job"
    }
  )
  
  description = "Glue ETL job with SQL connection for ${var.project_name}"
}

# Glue Trigger for Job (Optional - Scheduled)
resource "aws_glue_trigger" "job_trigger" {
  count = var.enable_schedule ? 1 : 0
  
  name     = "${var.project_name}-job-trigger-${var.environment}"
  type     = "SCHEDULED"
  schedule = var.job_schedule
  enabled  = var.trigger_enabled
  
  actions {
    job_name = aws_glue_job.etl_job.name
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-job-trigger"
    }
  )
}

# CloudWatch Log Group for Glue Job
resource "aws_cloudwatch_log_group" "glue_job_logs" {
  name              = "/aws-glue/jobs/${aws_glue_job.etl_job.name}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-glue-logs"
    }
  )
}
