# Dockerfile for GluePipeline CLI
FROM python:3.9-slim

LABEL maintainer="GluePipeline Team"
LABEL description="DataDevOps CLI for AWS Glue Pipeline Management"

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY cli.py /app/
COPY requirements.txt /app/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make CLI executable
RUN chmod +x /app/cli.py

# Create volume mount point for configurations
VOLUME ["/workspace"]

# Set environment variables
ENV GLUE_CONFIG=/workspace/config.json
ENV PYTHONUNBUFFERED=1

# Default command
ENTRYPOINT ["python", "/app/cli.py"]
CMD ["--help"]
