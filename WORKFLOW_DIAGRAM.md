# Terraform Action Workflow Diagram

## Workflow Trigger Flow

```
User triggers workflow via GitHub UI
         ↓
    [Select Parameters]
         ↓
┌────────────────────────┐
│ terraform_module: glue │
│ environment: dev/prod  │
│ terraform_action: ?    │
└────────────────────────┘
         ↓
    ┌────┴────┐
    │ Action? │
    └─┬──┬──┬─┘
      │  │  │
      │  │  └─────────────┐
      │  │                │
      │  └──────────┐     │
      │             │     │
   [plan]       [apply] [destroy]
      │             │     │
      ↓             ↓     ↓
  No Approval   Approval Approval
      │         Required Required
      │             │     │
      ↓             ↓     ↓
```

## Detailed Flow by Action

### Plan Action (No Approval)
```
┌─────────────────────────────────────────┐
│ terraform-action job starts immediately │
└─────────────────┬───────────────────────┘
                  ↓
         ┌────────────────┐
         │ Checkout Code  │
         └────────┬───────┘
                  ↓
         ┌────────────────┐
         │ Setup Terraform│
         └────────┬───────┘
                  ↓
         ┌────────────────┐
         │ Terraform Init │
         └────────┬───────┘
                  ↓
       ┌──────────────────┐
       │Terraform Validate│
       └──────────┬───────┘
                  ↓
         ┌────────────────┐
         │ Terraform Plan │
         │ (Show Changes) │
         └────────┬───────┘
                  ↓
              ✅ Done
       (Review plan output)
```

### Apply Action (With Approval)
```
┌──────────────────────────────────────────┐
│ terraform-action job waits for approval  │
│ Environment: terraform-apply-{env}       │
└──────────────┬───────────────────────────┘
               ↓
    ┌──────────────────────┐
    │ ⏸️  WAITING FOR       │
    │   APPROVAL            │
    │                       │
    │ Reviewers notified    │
    └──────────┬────────────┘
               ↓
    ┌──────────────────────┐
    │ Reviewer approves?    │
    └──────┬───────┬────────┘
         No│       │Yes
           │       ↓
           │  ┌────────────────┐
           │  │ Checkout Code  │
           │  └────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │ Setup Terraform│
           │  └────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │ Terraform Init │
           │  └────────┬───────┘
           │           ↓
           │ ┌──────────────────┐
           │ │Terraform Validate│
           │ └──────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │ Terraform Plan │
           │  │  (Save tfplan) │
           │  └────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │ Terraform Apply│
           │  │  (Auto-approve)│
           │  └────────┬───────┘
           │           ↓
           │       ✅ Done
           │   (Infrastructure
           │     deployed)
           ↓
       ❌ Rejected
    (Job cancelled)
```

### Destroy Action (With Approval)
```
┌──────────────────────────────────────────┐
│ terraform-action job waits for approval  │
│ Environment: terraform-destroy-{env}     │
└──────────────┬───────────────────────────┘
               ↓
    ┌──────────────────────┐
    │ ⏸️  WAITING FOR       │
    │   APPROVAL            │
    │                       │
    │ Reviewers notified    │
    └──────────┬────────────┘
               ↓
    ┌──────────────────────┐
    │ Reviewer approves?    │
    └──────┬───────┬────────┘
         No│       │Yes
           │       ↓
           │  ┌────────────────┐
           │  │ Checkout Code  │
           │  └────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │ Setup Terraform│
           │  └────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │ Terraform Init │
           │  └────────┬───────┘
           │           ↓
           │ ┌──────────────────┐
           │ │Terraform Validate│
           │ └──────────┬───────┘
           │           ↓
           │  ┌────────────────┐
           │  │Terraform Destroy│
           │  │  (Auto-approve)│
           │  └────────┬───────┘
           │           ↓
           │       ✅ Done
           │  (Infrastructure
           │     destroyed)
           ↓
       ❌ Rejected
    (Job cancelled)
```

## Environment-Based Approval Matrix

| Action  | Environment | Approval Required? | GitHub Environment Name    |
|---------|-------------|-------------------|----------------------------|
| plan    | dev         | ❌ No             | (none)                     |
| plan    | prod        | ❌ No             | (none)                     |
| apply   | dev         | ✅ Yes            | terraform-apply-dev        |
| apply   | prod        | ✅ Yes            | terraform-apply-prod       |
| destroy | dev         | ✅ Yes            | terraform-destroy-dev      |
| destroy | prod        | ✅ Yes            | terraform-destroy-prod     |

## Approval Configuration Examples

### Conservative (Recommended for Production)
```yaml
terraform-apply-prod:
  required_reviewers:
    - senior-devops-team
    - team-lead
  wait_timer: 300  # 5 minutes
  deployment_branches:
    - main
```

### Standard (For Development)
```yaml
terraform-apply-dev:
  required_reviewers:
    - devops-team
  wait_timer: 0
  deployment_branches:
    - all
```

### Critical Operations (For Destroy in Production)
```yaml
terraform-destroy-prod:
  required_reviewers:
    - senior-devops-team
    - team-lead
    - security-team
  wait_timer: 600  # 10 minutes
  deployment_branches:
    - main
```

## Key Features

### Safety Mechanisms
- ✅ **Plan first**: Always review changes before applying
- ✅ **Approval gates**: Human review required for apply/destroy
- ✅ **Multiple reviewers**: Support for multiple approval levels
- ✅ **Wait timers**: Enforced review period before deployment
- ✅ **Branch restrictions**: Control which branches can deploy
- ✅ **Audit trail**: All actions logged in GitHub Actions

### Flexibility
- 🔄 **Three actions**: plan, apply, destroy
- 🎯 **Multiple modules**: Support for different Terraform modules
- 🌍 **Multiple environments**: dev, prod, and more
- 📋 **Dynamic job names**: Clear identification in UI
- 💬 **Clear summaries**: Helpful output messages

### Security
- 🔒 **Secret management**: AWS credentials in GitHub Secrets
- 🛡️ **Approval required**: No accidental deployments/deletions
- 📊 **Full logging**: Complete audit trail
- 🔐 **Environment protection**: Branch and reviewer controls
