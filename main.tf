# dynamodb table. Core database for our application.

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "products"
  hash_key  = "name"
  range_key = "vendor"

  attributes = [
    {
      name = "name"
      type = "S"
    },
    {
      name = "vendor"
      type = "S"
    }
  ]
}
