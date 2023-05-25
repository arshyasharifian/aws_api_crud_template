data "aws_iam_policy_document" "api_gateway_lambda_access" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
        type = "Service"
        identifiers = ["apigateway.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "apigw_invoke_function" {
    statement {
      actions = ["lambda:InvokeFunction"]
      resources = ["${module.create_ts.lambda_function_arn}*", 
                  "${module.delete_ts.lambda_function_arn}*",
                  "${module.get_ts.lambda_function_arn}*",
                  "${module.put_ts.lambda_function_arn}*"
                  ]
      effect = "Allow"
    }
}

resource "aws_iam_role" "apigw_invoke_function" {
    name = "apigw-role-${var.service_name}-${terraform.workspace}"
    assume_role_policy = data.aws_iam_policy_document.api_gateway_lambda_access.json
    inline_policy {
      name = "apigw_lambda_invoke_function"
      policy = data.aws_iam_policy_document.apigw_invoke_function.json
    }
}