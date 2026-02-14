# Outputs for AWS Glue Infrastructure

output "glue_job_name" {
  description = "Name of the Glue job"
  value       = aws_glue_job.etl_job.name
}

output "glue_job_arn" {
  description = "ARN of the Glue job"
  value       = aws_glue_job.etl_job.arn
}

output "glue_job_id" {
  description = "ID of the Glue job"
  value       = aws_glue_job.etl_job.id
}

output "glue_role_arn" {
  description = "ARN of the IAM role used by Glue job"
  value       = aws_iam_role.glue_role.arn
}

output "glue_role_name" {
  description = "Name of the IAM role used by Glue job"
  value       = aws_iam_role.glue_role.name
}

output "glue_connection_name" {
  description = "Name of the Glue SQL connection"
  value       = aws_glue_connection.sql_connection.name
}

output "glue_connection_id" {
  description = "ID of the Glue SQL connection"
  value       = aws_glue_connection.sql_connection.id
}

output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.glue_database.name
}

output "glue_database_id" {
  description = "ID of the Glue catalog database"
  value       = aws_glue_catalog_database.glue_database.id
}

output "scripts_bucket_name" {
  description = "Name of the S3 bucket for Glue scripts"
  value       = aws_s3_bucket.glue_scripts.bucket
}

output "scripts_bucket_arn" {
  description = "ARN of the S3 bucket for Glue scripts"
  value       = aws_s3_bucket.glue_scripts.arn
}

output "temp_bucket_name" {
  description = "Name of the S3 bucket for Glue temporary files"
  value       = aws_s3_bucket.glue_temp.bucket
}

output "temp_bucket_arn" {
  description = "ARN of the S3 bucket for Glue temporary files"
  value       = aws_s3_bucket.glue_temp.arn
}

output "glue_job_script_location" {
  description = "Full S3 path to the Glue job script"
  value       = "s3://${aws_s3_bucket.glue_scripts.bucket}/${var.script_location}"
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for Glue job"
  value       = aws_cloudwatch_log_group.glue_job_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for Glue job"
  value       = aws_cloudwatch_log_group.glue_job_logs.arn
}

output "glue_trigger_name" {
  description = "Name of the Glue trigger (if enabled)"
  value       = var.enable_schedule ? aws_glue_trigger.job_trigger[0].name : null
}

output "glue_trigger_id" {
  description = "ID of the Glue trigger (if enabled)"
  value       = var.enable_schedule ? aws_glue_trigger.job_trigger[0].id : null
}
