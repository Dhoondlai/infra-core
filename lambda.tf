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

  function_name                     = "backend-dhoondlai"
  description                       = "Backend for Dhoondlai app. Express Monolith."
  handler                           = "dist/server.handler"
  runtime                           = "nodejs20.x"
  create_lambda_function_url        = true
  authorization_type                = "AWS_IAM"
  create_package                    = false
  local_existing_package            = "code.zip"
  ignore_source_code_hash           = true
  cloudwatch_logs_retention_in_days = 3

  create_role = false
  lambda_role = aws_iam_role.backend_lambda_role.arn

  cors = {
    allow_headers  = ["*"]
    allow_methods  = ["GET", "POST", "PATCH", "DELETE"]
    expose_headers = ["*"]
    allow_origins  = ["https://dhoondlai.com"]
  }

  environment_variables = {
    ENVIRONMENT = "production"
  }

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
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 900

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
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 900


  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

module "rbtechngames" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "rbtechngames-scraper"
  description             = "RB Tech N Games Scraper"
  handler                 = "rbtechngames.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.scraper_layer.arn
  ]
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 900


  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

module "buyerspk" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "buyerspk-scraper"
  description             = "Buyerspk Scraper"
  handler                 = "buyerspk.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.scraper_layer.arn
  ]
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 900

  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

module "gamerz" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "gamerz-scraper"
  description             = "Gamerz Scraper"
  handler                 = "gamerz.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.scraper_layer.arn
  ]
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 900

  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

module "walistech" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "walistech-scraper"
  description             = "Walistech Scraper"
  handler                 = "walistech.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.scraper_layer.arn
  ]
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 900

  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

# module "connect2aryans" {
#   source = "terraform-aws-modules/lambda/aws"

#   function_name           = "connect2aryans-scraper"
#   description             = "Connect2Aryans Scraper"
#   handler                 = "connect2aryans.run"
#   runtime                 = "python3.12"
#   create_package          = false
#   local_existing_package  = "code.zip"
#   ignore_source_code_hash = true
#   layers = [
#     aws_lambda_layer_version.scraper_layer.arn
#   ]
#   cloudwatch_logs_retention_in_days = 1
#   timeout                           = 900

#   create_role = false
#   lambda_role = aws_iam_role.scraper_lambda_role.arn
# }

module "db_updator" {
  source = "terraform-aws-modules/lambda/aws"

  function_name           = "db-updator"
  description             = "Function to standardize product names in database."
  handler                 = "db_update_products.run.run"
  runtime                 = "python3.12"
  create_package          = false
  local_existing_package  = "code.zip"
  ignore_source_code_hash = true
  layers = [
    aws_lambda_layer_version.db_updator_layer.arn
  ]
  cloudwatch_logs_retention_in_days = 1
  timeout                           = 60


  create_role = false
  lambda_role = aws_iam_role.scraper_lambda_role.arn
}

# lambda layers

resource "aws_lambda_layer_version" "scraper_layer" {
  filename   = "lambda_layers/scraper_layer_content.zip"
  layer_name = "scraper_layer"
  compatible_runtimes = [
    "python3.12"
  ]
  source_code_hash = filebase64sha256("lambda_layers/scraper_layer_content.zip")
}

resource "aws_lambda_layer_version" "db_updator_layer" {
  filename   = "lambda_layers/db_updator_layer_content.zip"
  layer_name = "db_updator_layer"
  compatible_runtimes = [
    "python3.12"
  ]
  source_code_hash = filebase64sha256("lambda_layers/db_updator_layer_content.zip")
}
