
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

  ignore_source_code_hash = true
}
