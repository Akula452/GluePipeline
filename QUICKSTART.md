# Quick Start Guide - GluePipeline CLI

This guide will help you get started with the GluePipeline CLI quickly.

## Option 1: Local Installation (Fastest)

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run the demo
bash examples/demo.sh

# 3. Start using the CLI
python cli.py init --name my-pipeline --environment dev
python cli.py add-job --job-name etl-job --script s3://bucket/script.py
python cli.py list
python cli.py validate
python cli.py deploy
```

## Option 2: Docker (Recommended for Production)

```bash
# 1. Build the Docker image
docker build -t gluepipeline-cli:latest .

# 2. Create a workspace
mkdir -p workspace

# 3. Run CLI commands
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest init --name my-pipeline

docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest add-job --job-name job1 --script s3://bucket/script.py

docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest list

docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest deploy
```

## Option 3: Docker Compose (Best for Development)

```bash
# 1. Build with docker compose
docker compose build

# 2. Run commands
docker compose run --rm gluepipeline-cli init --name my-pipeline

docker compose run --rm gluepipeline-cli add-job --job-name etl-job --script s3://bucket/script.py

docker compose run --rm gluepipeline-cli list

# 3. Use development container for interactive work
docker compose run --rm gluepipeline-dev /bin/bash
```

## Basic Workflow

1. **Initialize Pipeline**
   ```bash
   python cli.py init --name my-etl-pipeline --environment dev
   ```

2. **Add Jobs**
   ```bash
   python cli.py add-job --job-name extract --script s3://bucket/extract.py
   python cli.py add-job --job-name transform --script s3://bucket/transform.py
   python cli.py add-job --job-name load --script s3://bucket/load.py
   ```

3. **Validate Configuration**
   ```bash
   python cli.py validate
   ```

4. **Review Status**
   ```bash
   python cli.py status
   python cli.py list
   ```

5. **Deploy**
   ```bash
   python cli.py deploy --environment production
   ```

## Environment Variables (Optional)

Set these for AWS integration:

```bash
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export GLUE_CONFIG=/path/to/config.json  # Optional: custom config location
```

## Example Use Cases

### Use Case 1: Data Ingestion Pipeline
```bash
python cli.py init --name data-ingestion --environment dev
python cli.py add-job --job-name ingest-s3 --script s3://bucket/ingest.py
python cli.py add-job --job-name validate-data --script s3://bucket/validate.py
python cli.py validate
python cli.py deploy
```

### Use Case 2: ETL Pipeline
```bash
python cli.py init --name etl-pipeline --environment prod --glue-version 3.0
python cli.py add-job --job-name extract --script s3://bucket/extract.py
python cli.py add-job --job-name transform --script s3://bucket/transform.py
python cli.py add-job --job-name load --script s3://bucket/load.py
python cli.py validate
python cli.py deploy --environment prod
```

### Use Case 3: Data Quality Pipeline
```bash
python cli.py init --name quality-checks --environment dev
python cli.py add-job --job-name schema-check --script s3://bucket/schema.py
python cli.py add-job --job-name data-quality --script s3://bucket/quality.py
python cli.py validate
python cli.py deploy
```

## Troubleshooting

### Issue: "No pipeline initialized"
**Solution**: Run `python cli.py init --name your-pipeline` first

### Issue: Docker volume permission errors
**Solution**: Ensure the workspace directory has proper permissions:
```bash
mkdir -p workspace
chmod 755 workspace
```

### Issue: AWS credentials not working
**Solution**: Set environment variables or use AWS CLI configuration:
```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

## Next Steps

- Read the full [README.md](README.md) for complete documentation
- Check [examples/](examples/) for more usage examples
- Review the [GitHub workflow](.github/workflows/datadevops-pipeline.yml) for CI/CD integration
- Customize the CLI for your specific needs

## Getting Help

- Run `python cli.py --help` for command reference
- Run `python cli.py <command> --help` for command-specific help
- Check the examples directory for sample configurations
- Open an issue on GitHub for bugs or feature requests
