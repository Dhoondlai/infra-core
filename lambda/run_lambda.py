#!/usr/bin/env python3
import os
import sys
import argparse
import importlib
import time
import json
from datetime import datetime


# python3 run_lambda.py db_update_products --event '{"category": "Processor"}'

def run_lambda(lambda_name, event_data=None):
    # Set environment variable to indicate local execution
    os.environ["IS_LOCAL"] = "True"

    # Ensure the current directory is in the Python path
    lambda_dir = os.path.dirname(os.path.abspath(__file__))
    # Add infra-core parent directory
    sys.path.append(os.path.dirname(os.path.dirname(lambda_dir)))

    try:
        # Dynamically import the specified lambda module
        module_path = f"infra-core.lambda.{lambda_name}"

        print("Module path:", module_path)

        lambda_module = importlib.import_module(module_path)

        print("Lambda module:", lambda_module)

        print(f"Running {lambda_name} lambda function...")
        start_time = time.time()
        start_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"Start time: {start_datetime}")

        # Create mock event and context objects
        event = event_data or {}
        context = {}

        # Run the lambda function
        result = lambda_module.run(event, context)

        end_time = time.time()
        end_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        elapsed_seconds = end_time - start_time
        minutes = int(elapsed_seconds // 60)
        seconds = int(elapsed_seconds % 60)

        print(f"\n{lambda_name} lambda function completed successfully.")
        print(f"Start time: {start_datetime}")
        print(f"End time: {end_datetime}")
        print(f"Total execution time: {minutes} minutes and {seconds} seconds")
        print("\nResult:")
        print(json.dumps(result, indent=2))

    except ImportError as e:
        print(
            f"Error: Lambda '{lambda_name}' not found. Make sure it exists in the infra-core/lambda/ directory.")
        print(f"ImportError details: {str(e)}")
        return 1
    except Exception as e:
        print(f"Error running {lambda_name} lambda function: {str(e)}")
        return 1

    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Run a Lambda function locally.")
    parser.add_argument(
        "lambda_name", nargs='?', help="Name of the Lambda function to run (e.g., db_update_products)")
    parser.add_argument("--list", action="store_true",
                        help="List all available Lambda functions")
    parser.add_argument("--event", type=str,
                        help="JSON string with event data (e.g., '{\"category\": \"Processor\"}')")

    args = parser.parse_args()

    if args.list:
        # List all available Lambda functions
        lambda_dir = os.path.dirname(os.path.abspath(__file__))
        available_lambdas = [
            f[:-3] for f in os.listdir(lambda_dir)
            if f.endswith('.py') and not f.startswith('__') and f != 'run_lambda.py'
        ]
        print("Available Lambda functions:")
        for lambda_func in available_lambdas:
            print(f"  - {lambda_func}")
        sys.exit(0)

    # Check if Lambda name was provided
    if args.lambda_name is None:
        parser.print_help()
        print("\nError: You must specify a Lambda function name or use --list to see available functions.")
        sys.exit(1)

    # Parse event data if provided
    event_data = None
    if args.event:
        try:
            event_data = json.loads(args.event)
        except json.JSONDecodeError:
            print("Error: Invalid JSON format for event data.")
            sys.exit(1)

    # Run the specified Lambda function
    exit_code = run_lambda(args.lambda_name, event_data)
    sys.exit(exit_code)
