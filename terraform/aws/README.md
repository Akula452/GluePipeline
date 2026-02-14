# Terraform AWS Glue Infrastructure

This directory contains Terraform configuration for deploying AWS Glue jobs with SQL database connections.

## Overview

This Terraform module creates:
- **AWS Glue Job**: ETL job with SQL connection support
- **AWS Glue Connection**: JDBC connection to SQL database
- **AWS Glue Catalog Database**: Data catalog for metadata management
- **S3 Buckets**: Storage for Glue scripts and temporary files
- **IAM Role**: Execution role with appropriate permissions
- **CloudWatch Log Group**: Logging for job execution
- **Glue Trigger** (optional): Scheduled job execution

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create Glue resources
- VPC with subnets and security groups (for SQL connection)
- Database endpoint (RDS, Aurora, or other JDBC-compatible database)

## Directory Structure

```
terraform/aws/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables file
└── README.md                  # This file
```

## Quick Start

### 1. Configure Variables

Copy the example variables file and customize it:

```bash
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
aws_region   = "us-east-1"
project_name = "my-glue-project"
environment  = "dev"

# SQL Connection
jdbc_connection_url = "jdbc:postgresql://db.example.com:5432/mydb"
db_username         = "admin"
security_group_ids  = ["sg-xxxxxxxxx"]
subnet_id           = "subnet-xxxxxxxxx"
```

### 2. Set Database Password

Set the database password as an environment variable (recommended):

```bash
export TF_VAR_db_password="your-secure-password"
```

Or use AWS Secrets Manager (preferred for production).

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan Deployment

Review the resources that will be created:

```bash
terraform plan
```

### 5. Apply Configuration

Deploy the infrastructure:

```bash
terraform apply
```

### 6. Upload Glue Script

After applying, upload your ETL script to the created S3 bucket:

```bash
# Get the bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw scripts_bucket_name)

# Upload your script
aws s3 cp your-etl-script.py s3://${BUCKET_NAME}/scripts/etl_job.py
```

## Configuration Options

### Glue Job Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `glue_version` | Glue version to use | `4.0` |
| `worker_type` | Worker type (Standard, G.1X, G.2X, etc.) | `G.1X` |
| `number_of_workers` | Number of workers | `2` |
| `job_timeout` | Job timeout in minutes | `2880` |
| `python_version` | Python version | `3` |
| `script_location` | Script location in S3 bucket | `scripts/etl_job.py` |

### SQL Connection Configuration

| Variable | Description | Required |
|----------|-------------|----------|
| `jdbc_connection_url` | JDBC connection URL | Yes |
| `db_username` | Database username | Yes |
| `db_password` | Database password | Yes |
| `security_group_ids` | Security group IDs | No (required for VPC connectivity) |
| `subnet_id` | Subnet ID for connection | No (required for VPC connectivity) |
| `availability_zone` | Availability zone | No (required for VPC connectivity) |

**Note**: Network configuration (`security_group_ids`, `subnet_id`, `availability_zone`) is optional. If provided, the Glue connection will use VPC networking. If omitted, it will use public connectivity (ensure your database allows public access).

### Scheduling Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_schedule` | Enable scheduled trigger | `false` |
| `job_schedule` | Cron expression | `cron(0 12 * * ? *)` |
| `trigger_enabled` | Enable/disable trigger | `true` |

## JDBC Connection URLs

### PostgreSQL
```
jdbc:postgresql://hostname:5432/database
```

### MySQL
```
jdbc:mysql://hostname:3306/database
```

### SQL Server
```
jdbc:sqlserver://hostname:1433;databaseName=database
```

### Oracle
```
jdbc:oracle:thin:@hostname:1521:database
```

### Redshift
```
jdbc:redshift://hostname:5439/database
```

## Network Configuration

### Security Groups

Your security group should allow:
- **Outbound**: Connection to your database (e.g., port 5432 for PostgreSQL)
- **Inbound**: Self-referencing rule for Glue ENIs to communicate

Example security group rule:
```hcl
# Allow Glue to connect to database
egress {
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]  # Your VPC CIDR
}

# Allow Glue ENIs to communicate with each other
ingress {
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}
```

### Subnets

- Use private subnets for Glue connections
- Ensure subnets have routes to NAT Gateway for internet access
- Subnets should be in the same VPC as your database

## IAM Permissions

The created IAM role includes:
- AWS managed policy: `AWSGlueServiceRole`
- S3 access to scripts and temp buckets
- CloudWatch Logs access (via managed policy)

Additional permissions can be added by modifying the IAM policy in `main.tf`.

## Outputs

After applying, you can retrieve output values:

```bash
# Get Glue job name
terraform output glue_job_name

# Get all outputs
terraform output

# Get output in JSON format
terraform output -json
```

## Example ETL Script

Here's a basic example of a Glue ETL script that uses the SQL connection:

```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from database using Glue connection
datasource = glueContext.create_dynamic_frame.from_options(
    connection_type="postgresql",
    connection_options={
        "useConnectionProperties": "true",
        "dbtable": "public.source_table",
        "connectionName": "your-connection-name"
    }
)

# Transform data
transformed = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("id", "int", "id", "int"),
        ("name", "string", "name", "string")
    ]
)

# Write to S3 or another destination
glueContext.write_dynamic_frame.from_options(
    frame=transformed,
    connection_type="s3",
    connection_options={"path": "s3://bucket/output/"},
    format="parquet"
)

job.commit()
```

## Running the Glue Job

### Using AWS CLI

```bash
aws glue start-job-run --job-name $(terraform output -raw glue_job_name)
```

### Using AWS Console

1. Navigate to AWS Glue Console
2. Go to ETL Jobs
3. Select your job
4. Click "Run job"

### Monitoring

View job logs in CloudWatch:
```bash
LOG_GROUP=$(terraform output -raw cloudwatch_log_group_name)
aws logs tail $LOG_GROUP --follow
```

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including S3 buckets. Ensure you have backups of any important data.

## Best Practices

1. **Secrets Management**: Use AWS Secrets Manager or Parameter Store for database credentials
2. **State Management**: Store Terraform state in S3 with DynamoDB locking
3. **Tagging**: Use consistent tagging strategy for cost allocation
4. **Network Isolation**: Use private subnets for Glue connections
5. **Job Bookmarks**: Enable job bookmarks to process only new data
6. **Monitoring**: Enable CloudWatch metrics and set up alarms
7. **Version Control**: Track script versions in S3 using versioning

## Troubleshooting

### Connection Issues

If Glue cannot connect to the database:
1. Verify security group rules allow outbound traffic to database port
2. Check subnet routing (needs NAT Gateway for internet access)
3. Verify database security group allows inbound from Glue security group
4. Test connection using Glue Console's "Test connection" feature

### Job Failures

Check CloudWatch logs for detailed error messages:
```bash
aws logs tail /aws-glue/jobs/[job-name] --follow
```

Common issues:
- Incorrect JDBC URL format
- Invalid credentials
- Network connectivity problems
- Missing dependencies (JARs, Python packages)
- Insufficient IAM permissions

## Additional Resources

- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Glue Job Parameters](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-glue-arguments.html)
- [JDBC Drivers for Glue](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-connect.html)

## Support

For issues or questions:
- Create an issue in the repository
- Consult AWS Glue documentation
- Check AWS support forums

## License

This Terraform configuration is part of the GluePipeline project.
