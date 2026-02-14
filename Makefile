.PHONY: help build run test clean install demo docker-build docker-run compose-build compose-run

# Default target
help:
	@echo "GluePipeline CLI - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  install        - Install Python dependencies"
	@echo "  demo           - Run the demo script"
	@echo "  test           - Run CLI tests"
	@echo "  docker-build   - Build Docker image"
	@echo "  docker-run     - Run CLI with Docker (pass CMD=<command>)"
	@echo "  compose-build  - Build with Docker Compose"
	@echo "  compose-run    - Run with Docker Compose (pass CMD=<command>)"
	@echo "  clean          - Clean generated files"
	@echo ""
	@echo "Examples:"
	@echo "  make install"
	@echo "  make demo"
	@echo "  make docker-build"
	@echo "  make docker-run CMD='init --name test'"
	@echo "  make compose-run CMD='list'"

# Install dependencies
install:
	@echo "Installing dependencies..."
	pip install -r requirements.txt
	chmod +x cli.py examples/*.sh
	@echo "✅ Installation complete!"

# Run demo
demo:
	@echo "Running demo..."
	bash examples/demo.sh

# Test CLI
test:
	@echo "Testing CLI..."
	python cli.py --help
	python cli.py init --name test-pipeline --environment dev
	python cli.py add-job --job-name test-job --script s3://bucket/test.py
	python cli.py list
	python cli.py validate
	python cli.py status
	@echo "✅ All tests passed!"

# Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t gluepipeline-cli:latest .
	@echo "✅ Docker image built!"

# Run with Docker
docker-run: docker-build
	@mkdir -p workspace
	@if [ -z "$(CMD)" ]; then \
		docker run --rm -v $(PWD)/workspace:/workspace gluepipeline-cli:latest --help; \
	else \
		docker run --rm -v $(PWD)/workspace:/workspace gluepipeline-cli:latest $(CMD); \
	fi

# Build with Docker Compose
compose-build:
	@echo "Building with Docker Compose..."
	docker compose build
	@echo "✅ Docker Compose build complete!"

# Run with Docker Compose
compose-run: compose-build
	@mkdir -p workspace
	@if [ -z "$(CMD)" ]; then \
		docker compose run --rm gluepipeline-cli --help; \
	else \
		docker compose run --rm gluepipeline-cli $(CMD); \
	fi

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -f config.json
	rm -rf workspace/
	rm -rf __pycache__/
	rm -rf *.pyc
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Cleanup complete!"

# Quick start
quickstart: install
	@echo ""
	@echo "🚀 Quick start complete!"
	@echo ""
	@echo "Try these commands:"
	@echo "  python cli.py init --name my-pipeline"
	@echo "  python cli.py add-job --job-name job1 --script s3://bucket/script.py"
	@echo "  python cli.py list"
	@echo ""
