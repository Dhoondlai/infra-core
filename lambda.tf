
# Dummy file to act as a placeholder.
# All changes to the lambda function will be done in their separate repos.
# Only infra is managed here, nothing else.
# Do not make changes to this resource as it will result in a redeployment
# of the lambda function with the dummy content.
data "archive_file" "dummy_zip" {
  type        = "zip"
  output_path = "code.zip"
  source {
    content  = "dummy content"
    filename = "dummy.txt"
  }
}

resource "aws_iam_role" "backend_lambda_role" {
  name = "BackendLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com" # Allow Lambda to assume the role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role" "scraper_lambda_role" {
  name = "ScraperLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com" # Allow Lambda to assume the role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_access_policy" {
  name        = "SSMAccessPolicy"
  description = "Policy that allows access to AWS SSM"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters",
          "ssm:LabelParameter",
          "ssm:GetParameterHistory"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_access_policy_attachment_backend" {
  role       = aws_iam_role.backend_lambda_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_access_policy_attachment_scraper" {
  role       = aws_iam_role.scraper_lambda_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

# Attach AWSLambdaBasicExecutionRole managed policy to the role (for CloudWatch logging)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_backend" {
  role       = aws_iam_role.backend_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_scraper" {
  role       = aws_iam_role.scraper_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

module "backend-dhoondlai" {
  source = "terraform-aws-modules/lambda/aws"

  function_name              = "backend-dhoondlai"
  description                = "Backend for Dhoondlai app. Express Monolith."
  handler                    = "dist/server.handler"
  runtime                    = "nodejs20.x"
  create_lambda_function_url = true
  authorization_type         = "AWS_IAM"
  create_package             = false
  local_existing_package     = "code.zip"
  ignore_source_code_hash    = true

  create_role = false
  lambda_role = aws_iam_role.backend_lambda_role.arn
}


# scrapers
module "techmatched" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "techmatched-scraper"
  description             = "Techmatched Scraper"
  handler                 = "techmatched.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.scraper_layer.arn
  ]

  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

module "junaidtech" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "junaidtech-scraper"
  description             = "JunaidTech Scraper"
  handler                 = "junaidtech.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.scraper_layer.arn
  ]

  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

# lambda layer for scraper libraries (e.g bs4)
# layer content created via create_layer.sh script.

resource "aws_lambda_layer_version" "scraper_layer" {
  filename   = "scraper_layer_content.zip"
  layer_name = "scraper_layer"
  compatible_runtimes = [
    "python3.12"
  ]
  source_code_hash = filebase64sha256("scraper_layer_content.zip")
}
