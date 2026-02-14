# GluePipeline - DataDevOps CLI for AWS Glue

A comprehensive DataDevOps command-line tool for managing AWS Glue pipelines with Docker containerization support.

## 🚀 Features

- **CLI Interface**: Easy-to-use command-line tool for pipeline management
- **Docker Support**: Fully containerized for consistent execution across environments
- **Pipeline Management**: Initialize, configure, and deploy Glue pipelines
- **Job Management**: Add, list, and manage Glue jobs
- **Validation**: Built-in configuration validation
- **CI/CD Ready**: GitHub Actions workflow for automated testing and deployment

## 📋 Prerequisites

- Python 3.9+
- Docker (for containerized usage)
- Docker Compose (optional, for orchestration)
- AWS Account (for actual Glue deployments)

## 🛠️ Installation

### Local Installation

```bash
# Clone the repository
git clone https://github.com/Akula452/GluePipeline.git
cd GluePipeline

# Install dependencies
pip install -r requirements.txt

# Make CLI executable
chmod +x cli.py
```

### Docker Installation

```bash
# Build the Docker image
docker build -t gluepipeline-cli:latest .

# Or use Docker Compose
docker compose build
```

## 📖 Usage

### Local Usage

```bash
# Initialize a new pipeline
python cli.py init --name my-pipeline --environment dev

# Add jobs to the pipeline
python cli.py add-job --job-name etl-job1 --script s3://bucket/script.py

# List all jobs
python cli.py list

# Validate configuration
python cli.py validate

# Show pipeline status
python cli.py status

# Deploy the pipeline
python cli.py deploy --environment prod
```

### Docker Usage

```bash
# Create workspace directory
mkdir -p workspace

# Run commands with Docker
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest init --name my-pipeline

docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest add-job --job-name job1 --script s3://bucket/script.py

docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest list
```

### Docker Compose Usage

```bash
# Run CLI commands
docker compose run --rm gluepipeline-cli init --name my-pipeline --environment dev

docker compose run --rm gluepipeline-cli add-job --job-name etl-job --script s3://bucket/script.py

docker compose run --rm gluepipeline-cli list

# Use development container
docker compose run --rm gluepipeline-dev /bin/bash
```

## 📚 Commands

### `init` - Initialize Pipeline
```bash
python cli.py init --name PIPELINE_NAME [--environment ENV] [--glue-version VERSION]
```

### `add-job` - Add Job to Pipeline
```bash
python cli.py add-job --job-name JOB_NAME --script SCRIPT_PATH [--job-type TYPE]
```

### `list` - List All Jobs
```bash
python cli.py list
```

### `validate` - Validate Configuration
```bash
python cli.py validate
```

### `status` - Show Pipeline Status
```bash
python cli.py status
```

### `deploy` - Deploy Pipeline
```bash
python cli.py deploy [--environment ENV]
```

## 🔧 Configuration

The CLI stores configuration in `config.json` (or path specified by `GLUE_CONFIG` environment variable):

```json
{
  "pipeline_name": "my-pipeline",
  "created_at": "2026-02-14T00:00:00",
  "environment": "dev",
  "glue_version": "3.0",
  "jobs": [
    {
      "name": "job-name",
      "script": "s3://bucket/script.py",
      "type": "glueetl",
      "added_at": "2026-02-14T00:00:00"
    }
  ]
}
```

## 🔄 CI/CD Workflow

The repository includes a GitHub Actions workflow (`.github/workflows/datadevops-pipeline.yml`) that:

- Builds and tests the CLI
- Builds and tests Docker images
- Tests Docker Compose configuration
- Validates pipeline configurations
- Deploys to production (on main/dev branches)

### Workflow Triggers

- Push to `main`, `dev`, or `copilot/**` branches
- Pull requests to `main` or `dev`
- Manual workflow dispatch

## 📂 Project Structure

```
GluePipeline/
├── cli.py                          # Main CLI application
├── Dockerfile                      # Docker image definition
├── docker-compose.yml              # Docker Compose configuration
├── requirements.txt                # Python dependencies
├── README.md                       # This file
├── .gitignore                      # Git ignore rules
├── .github/
│   └── workflows/
│       └── datadevops-pipeline.yml # CI/CD workflow
├── examples/
│   ├── example-config.json         # Example configuration
│   ├── demo.sh                     # Demo script
│   └── docker-usage.sh             # Docker examples
└── terraform/
    └── aws/
        ├── main.tf                 # Main Terraform configuration
        ├── variables.tf            # Variable definitions
        ├── outputs.tf              # Output values
        ├── terraform.tfvars.example # Example variables file
        ├── example_glue_script.py  # Example Glue ETL script
        └── README.md               # Terraform documentation
```

## ☁️ Infrastructure as Code (Terraform)

The `terraform/aws/` directory contains Terraform configuration for deploying AWS Glue infrastructure:

### Features
- **AWS Glue Job**: ETL job with SQL connection support
- **SQL Connection**: JDBC connection to databases (PostgreSQL, MySQL, SQL Server, etc.)
- **S3 Buckets**: Storage for scripts and temporary files
- **IAM Role**: Execution role with appropriate permissions
- **CloudWatch Logs**: Job execution logging
- **Glue Trigger**: Optional scheduled job execution

### Quick Start with Terraform

```bash
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
terraform init
terraform plan
terraform apply
```

See [terraform/aws/README.md](terraform/aws/README.md) for detailed documentation.

## 🌍 Environment Variables

- `GLUE_CONFIG`: Path to configuration file (default: `config.json`)
- `AWS_REGION`: AWS region for Glue operations
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key

## 🧪 Examples

See the `examples/` directory for:
- Sample pipeline configurations
- Demo scripts
- Docker usage examples

Run the demo:
```bash
cd examples
chmod +x demo.sh
./demo.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- Akula Venkata

## 🐛 Issues

Report issues at: https://github.com/Akula452/GluePipeline/issues
