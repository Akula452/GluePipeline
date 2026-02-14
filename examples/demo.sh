#!/bin/bash
# Example usage script for GluePipeline CLI

set -e

echo "🚀 GluePipeline CLI Demo"
echo "========================"

# Initialize a new pipeline
echo ""
echo "1. Initializing pipeline..."
python cli.py init --name demo-pipeline --environment dev --glue-version 3.0

# Add some jobs
echo ""
echo "2. Adding jobs to pipeline..."
python cli.py add-job --job-name ingestion-job --script s3://bucket/ingest.py --job-type glueetl
python cli.py add-job --job-name transform-job --script s3://bucket/transform.py --job-type glueetl
python cli.py add-job --job-name load-job --script s3://bucket/load.py --job-type glueetl

# List all jobs
echo ""
echo "3. Listing all jobs..."
python cli.py list

# Validate configuration
echo ""
echo "4. Validating configuration..."
python cli.py validate

# Show status
echo ""
echo "5. Showing pipeline status..."
python cli.py status

# Simulate deployment
echo ""
echo "6. Deploying pipeline..."
python cli.py deploy --environment dev

echo ""
echo "✅ Demo completed successfully!"
