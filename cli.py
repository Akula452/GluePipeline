#!/usr/bin/env python3
"""
GluePipeline CLI - A DataDevOps tool for managing AWS Glue pipelines
"""
import argparse
import json
import sys
import os
from datetime import datetime


class GluePipelineCLI:
    """Main CLI class for GluePipeline management"""
    
    def __init__(self):
        self.config_file = os.getenv('GLUE_CONFIG', 'config.json')
    
    def load_config(self):
        """Load configuration from config file"""
        if os.path.exists(self.config_file):
            with open(self.config_file, 'r') as f:
                return json.load(f)
        return {}
    
    def save_config(self, config):
        """Save configuration to config file"""
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=2)
    
    def init_pipeline(self, args):
        """Initialize a new pipeline configuration"""
        print(f"🚀 Initializing GluePipeline: {args.name}")
        
        config = {
            'pipeline_name': args.name,
            'created_at': datetime.now().isoformat(),
            'environment': args.environment or 'dev',
            'glue_version': args.glue_version or '3.0',
            'jobs': []
        }
        
        self.save_config(config)
        print(f"✅ Pipeline '{args.name}' initialized successfully!")
        print(f"📝 Configuration saved to {self.config_file}")
        return 0
    
    def add_job(self, args):
        """Add a new job to the pipeline"""
        config = self.load_config()
        
        if not config:
            print("❌ Error: No pipeline initialized. Run 'init' first.")
            return 1
        
        job = {
            'name': args.job_name,
            'script': args.script,
            'type': args.job_type or 'glueetl',
            'added_at': datetime.now().isoformat()
        }
        
        config['jobs'].append(job)
        self.save_config(config)
        
        print(f"✅ Job '{args.job_name}' added to pipeline")
        return 0
    
    def list_jobs(self, args):
        """List all jobs in the pipeline"""
        config = self.load_config()
        
        if not config:
            print("❌ Error: No pipeline initialized.")
            return 1
        
        print(f"\n📋 Pipeline: {config.get('pipeline_name', 'Unknown')}")
        print(f"🌍 Environment: {config.get('environment', 'dev')}")
        print(f"\n📦 Jobs ({len(config.get('jobs', []))}):")
        
        for idx, job in enumerate(config.get('jobs', []), 1):
            print(f"  {idx}. {job['name']} ({job['type']})")
            print(f"     Script: {job['script']}")
        
        return 0
    
    def deploy(self, args):
        """Deploy the pipeline"""
        config = self.load_config()
        
        if not config:
            print("❌ Error: No pipeline initialized.")
            return 1
        
        print(f"🚀 Deploying pipeline: {config['pipeline_name']}")
        print(f"🌍 Environment: {args.environment or config.get('environment', 'dev')}")
        print(f"📦 Jobs to deploy: {len(config.get('jobs', []))}")
        
        # Simulate deployment
        for job in config.get('jobs', []):
            print(f"  ⏳ Deploying job: {job['name']}")
        
        print("✅ Pipeline deployed successfully!")
        return 0
    
    def validate(self, args):
        """Validate pipeline configuration"""
        config = self.load_config()
        
        if not config:
            print("❌ Error: No pipeline initialized.")
            return 1
        
        print("🔍 Validating pipeline configuration...")
        
        errors = []
        warnings = []
        
        # Basic validations
        if not config.get('pipeline_name'):
            errors.append("Pipeline name is missing")
        
        if not config.get('jobs'):
            warnings.append("No jobs defined in pipeline")
        
        for idx, job in enumerate(config.get('jobs', []), 1):
            if not job.get('name'):
                errors.append(f"Job {idx} is missing a name")
            if not job.get('script'):
                errors.append(f"Job {idx} is missing a script path")
        
        # Report results
        if errors:
            print(f"❌ Validation failed with {len(errors)} error(s):")
            for error in errors:
                print(f"   • {error}")
            return 1
        
        if warnings:
            print(f"⚠️  {len(warnings)} warning(s):")
            for warning in warnings:
                print(f"   • {warning}")
        
        print("✅ Pipeline configuration is valid!")
        return 0
    
    def status(self, args):
        """Show pipeline status"""
        config = self.load_config()
        
        if not config:
            print("❌ No pipeline configured")
            return 1
        
        print("\n" + "="*50)
        print(f"📊 PIPELINE STATUS")
        print("="*50)
        print(f"Pipeline Name: {config.get('pipeline_name', 'N/A')}")
        print(f"Environment: {config.get('environment', 'N/A')}")
        print(f"Glue Version: {config.get('glue_version', 'N/A')}")
        print(f"Created: {config.get('created_at', 'N/A')}")
        print(f"Total Jobs: {len(config.get('jobs', []))}")
        print("="*50 + "\n")
        
        return 0


def main():
    """Main entry point for the CLI"""
    parser = argparse.ArgumentParser(
        description='GluePipeline CLI - DataDevOps tool for AWS Glue pipelines',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s init --name my-pipeline --environment dev
  %(prog)s add-job --job-name etl-job1 --script s3://bucket/script.py
  %(prog)s list
  %(prog)s validate
  %(prog)s deploy --environment prod
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Init command
    init_parser = subparsers.add_parser('init', help='Initialize a new pipeline')
    init_parser.add_argument('--name', required=True, help='Pipeline name')
    init_parser.add_argument('--environment', help='Environment (dev/prod)', default='dev')
    init_parser.add_argument('--glue-version', help='AWS Glue version', default='3.0')
    
    # Add job command
    add_parser = subparsers.add_parser('add-job', help='Add a job to the pipeline')
    add_parser.add_argument('--job-name', required=True, help='Job name')
    add_parser.add_argument('--script', required=True, help='Script path')
    add_parser.add_argument('--job-type', help='Job type', default='glueetl')
    
    # List command
    subparsers.add_parser('list', help='List all jobs in the pipeline')
    
    # Deploy command
    deploy_parser = subparsers.add_parser('deploy', help='Deploy the pipeline')
    deploy_parser.add_argument('--environment', help='Target environment')
    
    # Validate command
    subparsers.add_parser('validate', help='Validate pipeline configuration')
    
    # Status command
    subparsers.add_parser('status', help='Show pipeline status')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return 1
    
    cli = GluePipelineCLI()
    
    # Route to appropriate handler
    handlers = {
        'init': cli.init_pipeline,
        'add-job': cli.add_job,
        'list': cli.list_jobs,
        'deploy': cli.deploy,
        'validate': cli.validate,
        'status': cli.status
    }
    
    handler = handlers.get(args.command)
    if handler:
        return handler(args)
    else:
        print(f"Unknown command: {args.command}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
