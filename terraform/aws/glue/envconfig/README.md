# Environment Configuration

This directory contains environment-specific configuration files for Terraform deployments.

## Structure

```
envconfig/
└── aws/
    ├── dev.tfvars   # Development environment configuration
    └── prod.tfvars  # Production environment configuration
```

## Usage

These `.tfvars` files contain environment-specific variable values that can be used with Terraform:

### Development Environment

```bash
cd terraform/aws
terraform plan -var-file="../../envconfig/aws/dev.tfvars"
terraform apply -var-file="../../envconfig/aws/dev.tfvars"
```

### Production Environment

```bash
cd terraform/aws
terraform plan -var-file="../../envconfig/aws/prod.tfvars"
terraform apply -var-file="../../envconfig/aws/prod.tfvars"
```

## Adding New Environments

To add a new environment (e.g., staging):

1. Create a new file: `envconfig/aws/staging.tfvars`
2. Copy the structure from an existing file
3. Customize the values for your environment
4. Deploy using: `terraform apply -var-file="../../envconfig/aws/staging.tfvars"`

## Configuration Variables

Each environment file should define:

- **AWS Configuration**: Region, account settings
- **Project Configuration**: Project name, environment identifier
- **Resource Configuration**: Worker types, number of workers, timeouts
- **Network Configuration**: VPC, subnets, security groups
- **Scheduling**: Job schedules, triggers
- **Logging**: CloudWatch retention settings

Refer to `terraform/aws/variables.tf` for all available variables.

## Security Notes

- **Never commit sensitive data** like passwords or access keys to version control
- Use environment variables for secrets: `export TF_VAR_db_password="your-password"`
- Consider using AWS Secrets Manager or Parameter Store for production credentials
- Ensure `.tfvars` files don't contain actual production secrets

## See Also

- [Terraform AWS Documentation](../terraform/aws/README.md)
- [Main Project Documentation](../README.md)
