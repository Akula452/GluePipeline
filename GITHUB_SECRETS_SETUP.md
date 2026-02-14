# GitHub Secrets Setup Guide

This document explains how to configure AWS credentials as GitHub Secrets for the GluePipeline CI/CD workflow.

## 🚨 CRITICAL SECURITY WARNING

**NEVER commit AWS credentials to your repository!**

- AWS Access Keys and Secret Keys are **highly sensitive**
- Always use GitHub Secrets for storing credentials
- Never share credentials in plain text or public channels
- Regularly rotate your AWS credentials
- Use AWS IAM best practices and least privilege principles

If you accidentally commit credentials, **immediately**:
1. Rotate the credentials in AWS IAM
2. Remove them from Git history
3. Review AWS CloudTrail for unauthorized access

## Required Secrets

The following secrets must be configured in your GitHub repository settings:

### 1. AWS_ACCESS_KEY_ID
- **Description**: Your AWS Access Key ID for authentication
- **Required**: Yes
- **Used in**: Deploy job in CI/CD pipeline

### 2. AWS_SECRET_ACCESS_KEY
- **Description**: Your AWS Secret Access Key for authentication
- **Required**: Yes
- **Used in**: Deploy job in CI/CD pipeline

### 3. AWS_REGION (Optional)
- **Description**: AWS region for your Glue operations
- **Required**: No (defaults to `us-east-1`)
- **Example values**: `us-east-1`, `us-west-2`, `eu-west-1`, etc.

## How to Add Secrets to GitHub

### Step 1: Navigate to Repository Settings
1. Go to your GitHub repository: https://github.com/Akula452/GluePipeline
2. Click on **Settings** (top menu bar)
3. In the left sidebar, click **Secrets and variables** → **Actions**

### Step 2: Add New Repository Secret
1. Click the **New repository secret** button
2. Enter the secret name: `AWS_ACCESS_KEY_ID`
3. Enter the secret value: Your AWS Access Key ID (e.g., starts with `AKIA...`)
4. Click **Add secret**

### Step 3: Add AWS_SECRET_ACCESS_KEY
1. Click **New repository secret** again
2. Enter the secret name: `AWS_SECRET_ACCESS_KEY`
3. Enter your AWS Secret Access Key value (the secret key that corresponds to your Access Key ID)
   - **CRITICAL**: This is extremely sensitive - keep it secret!
   - Example format: A 40-character string of letters, numbers, and special characters
   - Never share this value or commit it to the repository
4. Click **Add secret**

### Step 4: Add AWS_REGION (Optional)
1. Click **New repository secret** again
2. Enter the secret name: `AWS_REGION`
3. Enter your preferred AWS region (e.g., `us-east-1`)
4. Click **Add secret**

## Using Secrets in Different Branches

GitHub Secrets are available to all branches in the repository. Once you add the secrets to the repository settings, they will be accessible in workflows running on:
- `main` branch
- `dev` branch
- `int` branch
- `copilot/**` branches
- Any other branches

## Security Best Practices

⚠️ **IMPORTANT SECURITY NOTES**:

1. **Never commit credentials to the repository**: Always use GitHub Secrets for sensitive data
2. **Rotate credentials regularly**: Change your AWS credentials periodically
3. **Use least privilege**: Ensure the AWS credentials have only the minimum required permissions
4. **Monitor usage**: Regularly check AWS CloudTrail for unexpected access patterns
5. **Use environment protection rules**: For production deployments, consider using GitHub Environment protection rules

## Verifying Secret Configuration

After adding the secrets, you can verify they're configured correctly by:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. You should see the secrets listed (values are hidden for security)
3. Run the CI/CD workflow to test the configuration

## Troubleshooting

### Secret not found error
- Verify the secret name matches exactly (case-sensitive)
- Ensure the secret is added to the repository (not organization or environment level)
- Check that the workflow file correctly references `${{ secrets.SECRET_NAME }}`

### Authentication failures
- Verify the AWS credentials are correct and active
- Ensure the IAM user/role has necessary permissions for Glue operations
- Check if the credentials have been rotated or expired

## Reference

For more information, see:
- [GitHub Actions Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GluePipeline README](README.md)

## Quick Reference: Secrets to Add

Use the GitHub UI (Settings → Secrets and variables → Actions) to add these secrets:

| Secret Name | Description | Example Format | Required |
|------------|-------------|----------------|----------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIA...` (20 characters) | ✅ Yes |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | 40 characters | ✅ Yes |
| `AWS_REGION` | AWS region for operations | `us-east-1`, `us-west-2`, etc. | ❌ No (defaults to `us-east-1`) |

**Remember**: These secrets are available to workflows on ALL branches (main, dev, int, copilot/**, etc.) once added to the repository settings.
