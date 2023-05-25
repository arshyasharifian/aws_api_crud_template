module "create_ts" {
  source = "terraform-aws-modules/lambda/aws"
  version = "3.1.1"
  
  description = "Create"
  function_name = "lambda-create-${terraform.workspace}"
  handler = "handler.default"
  runtime = "nodejs16.x"
  memory_size = 1024
  timeout = 15

  publish = true

  create_package = false
  local_existing_package = "${path.module}/../dist/lambda-create.zip"
  attach_policy_json = true
  number_of_policies = 1
  policy_json = data.aws_iam_policy_document.create_lambda_access.json

  architectures = ["arm64"]

  environment_variables = local.environment_variables
}

data "aws_iam_policy_document" "create_lambda_access" {
  statement {
    actions = ["dynamodb:PutItem"]
    resources = [module.dynamodb_table.dynamodb_table_arn]
    effect = "Allow"
  }
}