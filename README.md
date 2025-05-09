# Dhoondlai Infrastructure Core

Core infrastructure for the Dhoondlai app, managed with Terraform.

## Overview

This repository contains the Terraform code that defines and provisions the infrastructure for the Dhoondlai application. The infrastructure includes:

- AWS Lambda functions for backend services and data scrapers
- MongoDB Atlas database and users
- Cloudflare DNS records and Pages setup
- AWS CloudFront distributions
- AWS IAM roles and policies
- AWS Lambda layers

## Architecture

The Dhoondlai application infrastructure consists of the following components:

- **Frontend**: Hosted on Cloudflare Pages
- **Backend API**: AWS Lambda function with Express.js, exposed via CloudFront
- **Database**: MongoDB Atlas cluster
- **Scrapers**: Multiple AWS Lambda functions for scraping product data from various sources
- **Data Processors**: Lambda functions for data processing and standardization

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version ~> 1.0)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)
- [Python 3.12](https://www.python.org/downloads/) (for local development and Lambda layer creation)

## AWS Parameter Store Secrets

**IMPORTANT**: The following secrets must be manually created in AWS Parameter Store before deployment:

- `groq-api-key`: API key for the Groq service used in the db_update_products Lambda
- `mongo-uri`: MongoDB Atlas connection URI

These secrets are accessed by Lambda functions at runtime and are not managed by Terraform.

## Required Terraform Variables

Create a `.tfvars` file (e.g., `secrets.tfvars`) with the following variables:

```hcl
cloudflare_api_key        = "your-cloudflare-api-key"
cloudflare_account_email  = "your-cloudflare-email"
cloudflare_account_id     = "your-cloudflare-account-id"
cloudflare_main_zone_id   = "your-cloudflare-zone-id"
mongodbatlas_public_key   = "your-mongodb-atlas-public-key"
mongodbatlas_private_key  = "your-mongodb-atlas-private-key"
```

## Lambda Layers

The project uses Lambda layers to share dependencies between functions:

### Scraper Layer

Contains dependencies for web scraping:

- beautifulsoup4
- requests
- pymongo
- pymongo-auth-aws

To create the layer:

```bash
cd lambda_layers
./create_scraper_layer.sh
```

### DB Updator Layer

Contains dependencies for database operations:

- groq
- pymongo
- pymongo-auth-aws

To create the layer:

```bash
cd lambda_layers
./create_db_updator_layer.sh
```

## Lambda Functions

### Backend

The main API backend for the Dhoondlai application:

- Node.js 20.x runtime
- Express.js framework
- Exposed via CloudFront with custom domain (api.dhoondlai.com)

### Scrapers

Multiple scrapers for different product sources:

- techmatched
- junaidtech
- rbtechngames
- buyerspk
- gamerz
- walistech

### Data Processors

- `db-updator`: Standardizes product names in the database using Groq AI

## Running Lambda Functions Locally

You can test Lambda functions locally using the `run_lambda.py` script:

```bash
cd lambda
python3 run_lambda.py db_update_products --event '{"category": "Processor"}'
```

List available Lambda functions:

```bash
python3 run_lambda.py --list
```

## CI/CD

This repository uses GitHub Actions for CI/CD:

- On pull requests: Runs `terraform plan`
- On push to main: Runs `terraform apply`

Required secrets for GitHub Actions:

- AWS_ACCESS_KEY
- AWS_SECRET_ACCESS_KEY
- CLOUDFLARE_API_KEY
- CLOUDFLARE_ACCOUNT_EMAIL
- CLOUDFLARE_ZONE_ID
- CLOUDFLARE_ACCOUNT_ID
- MONGODBATLAS_PUBLIC_KEY
- MONGODBATLAS_PRIVATE_KEY

## Deployment

1. Create all necessary secrets in AWS Parameter Store.
2. Create the Lambda layers:
   ```bash
   cd lambda_layers
   ./create_scraper_layer.sh
   ./create_db_updator_layer.sh
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Apply the Terraform configuration:
   ```bash
   terraform apply -var-file=secrets.tfvars
   ```

## Notes

- Changes to Lambda function code should be made in their respective repositories.
- This repository only handles infrastructure and Lambda layer updates.
- The code.zip file is a dummy file that doesn't contain actual Lambda code.
