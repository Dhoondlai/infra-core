# dynamodb table. Core database for our application.

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "products"
  hash_key  = "name"
  range_key = "cost"

  attributes = [
    {
      name = "name"
      type = "S"
    },
    {
      name = "cost"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}
