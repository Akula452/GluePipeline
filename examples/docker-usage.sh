#!/bin/bash
# Docker usage examples for GluePipeline CLI

echo "🐳 GluePipeline Docker Usage Examples"
echo "======================================"

echo ""
echo "Building the Docker image..."
docker build -t gluepipeline-cli:latest .

echo ""
echo "Running CLI commands with Docker:"
echo ""

# Create workspace directory
mkdir -p workspace

# Example 1: Show help
echo "Example 1: Show help"
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest --help

# Example 2: Initialize pipeline
echo ""
echo "Example 2: Initialize pipeline"
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest init --name docker-pipeline --environment dev

# Example 3: Add job
echo ""
echo "Example 3: Add job"
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest add-job --job-name etl-job --script s3://bucket/script.py

# Example 4: List jobs
echo ""
echo "Example 4: List jobs"
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest list

# Example 5: Validate
echo ""
echo "Example 5: Validate configuration"
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest validate

# Example 6: Show status
echo ""
echo "Example 6: Show status"
docker run --rm -v $(pwd)/workspace:/workspace gluepipeline-cli:latest status

echo ""
echo "✅ Docker examples completed!"
echo ""
echo "To use Docker Compose:"
echo "  docker compose run gluepipeline-cli --help"
echo "  docker compose run gluepipeline-cli init --name my-pipeline"
