# Terraform Action Workflow Setup

## Overview
The workflow now includes a `terraform-action` stage that supports three operations:
- **plan**: Preview infrastructure changes (no approval required)
- **apply**: Apply infrastructure changes (approval required)
- **destroy**: Destroy infrastructure (approval required)

## Workflow Parameters

When triggering the workflow manually via GitHub Actions UI, you'll see these parameters:

1. **terraform_module**: Select the Terraform module to deploy (default: `glue`)
2. **environment**: Select the deployment environment (`dev` or `prod`)
3. **terraform_action**: Select the action to perform:
   - `plan` - Preview changes without applying
   - `apply` - Apply infrastructure changes (requires approval)
   - `destroy` - Destroy infrastructure (requires approval)

## Setting Up Approvals for Apply and Destroy Actions

To enable approval requirements for `apply` and `destroy` actions, you need to configure GitHub Environments:

### Step 1: Create GitHub Environments

For each combination of action and environment, create the following GitHub Environments in your repository:

#### For Dev Environment:
- `terraform-apply-dev`
- `terraform-destroy-dev`

#### For Prod Environment:
- `terraform-apply-prod`
- `terraform-destroy-prod`

### Step 2: Configure Environments with Required Reviewers

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Environments**
3. Click **New environment** or select an existing environment
4. For each environment (e.g., `terraform-apply-dev`):
   - Add **Required reviewers**: Select users or teams who must approve
   - Optionally set **Wait timer**: Delay before deployment can proceed
   - Optionally configure **Deployment branches**: Restrict which branches can deploy

### Example Configuration:

#### terraform-apply-dev
- **Required reviewers**: DevOps team members
- **Wait timer**: 0 minutes (optional)
- **Deployment branches**: All branches (or specific branches like `main`, `dev`)

#### terraform-apply-prod
- **Required reviewers**: Senior DevOps + Team Lead (multiple reviewers recommended)
- **Wait timer**: 5 minutes (optional, for review time)
- **Deployment branches**: Only `main` branch

#### terraform-destroy-dev
- **Required reviewers**: DevOps team members
- **Wait timer**: 0 minutes (optional)
- **Deployment branches**: All branches

#### terraform-destroy-prod
- **Required reviewers**: Multiple senior team members (strict approval)
- **Wait timer**: 10 minutes (recommended for critical actions)
- **Deployment branches**: Only `main` branch

## How It Works

### Plan Action (No Approval)
When you select `plan` action:
1. Workflow checks out code
2. Initializes Terraform
3. Validates configuration
4. Runs `terraform plan` to show proposed changes
5. No approval required - runs immediately

### Apply Action (Approval Required)
When you select `apply` action:
1. Workflow starts and waits for approval
2. GitHub will notify configured reviewers
3. Reviewers can review the workflow details and approve/reject
4. Once approved:
   - Checks out code
   - Initializes Terraform
   - Validates configuration
   - Runs `terraform plan` to create execution plan
   - Applies changes with `terraform apply`

### Destroy Action (Approval Required)
When you select `destroy` action:
1. Workflow starts and waits for approval
2. GitHub will notify configured reviewers
3. Reviewers can review the workflow details and approve/reject
4. Once approved:
   - Checks out code
   - Initializes Terraform
   - Validates configuration
   - Destroys infrastructure with `terraform destroy`

## Running the Workflow

1. Go to **Actions** tab in your GitHub repository
2. Select **DataDevOps Pipeline CI/CD** workflow
3. Click **Run workflow** button
4. Select parameters:
   - Choose **terraform_module** (e.g., `glue`)
   - Choose **environment** (e.g., `dev` or `prod`)
   - Choose **terraform_action** (e.g., `plan`, `apply`, or `destroy`)
5. Click **Run workflow**

### For Plan:
- Workflow runs immediately and shows proposed changes

### For Apply or Destroy:
- Workflow waits for approval
- Configured reviewers receive notification
- Reviewers approve or reject via GitHub UI
- Upon approval, workflow executes the action

## Security Best Practices

1. **Always run `plan` first**: Review changes before applying
2. **Require multiple reviewers for production**: Especially for `destroy` actions
3. **Use wait timers**: Give reviewers time to thoroughly review
4. **Restrict deployment branches**: Limit which branches can trigger applies/destroys
5. **Audit logs**: Review GitHub Actions logs regularly
6. **AWS credentials**: Ensure secrets are properly configured and rotated

## Required Secrets

Ensure the following secrets are configured in repository settings:
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_REGION`: AWS region (optional, defaults to us-east-1)
- `DB_PASSWORD`: Database password (if required by Terraform)

## Troubleshooting

### Workflow doesn't wait for approval
- Verify the environment name matches the expected format: `terraform-{action}-{env}`
- Check that environments are properly configured in repository settings
- Ensure you're using `apply` or `destroy` action (plan doesn't require approval)

### Approval not working
- Verify reviewers have proper permissions
- Check that reviewers are added to the environment configuration
- Ensure reviewers have access to the repository

### Terraform errors
- Check AWS credentials are properly configured
- Verify tfvars files exist for the selected environment
- Review Terraform state and backend configuration
- Check working directory paths are correct
