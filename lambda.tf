
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
}
