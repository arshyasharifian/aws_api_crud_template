resource "aws_route53_zone" "generic_zone" {
  name = "${var.domain_name}.com"
}

# creates the acm record
resource "aws_acm_certificate" "certificate_request" {
  domain_name = "*.${var.domain_name}.com"
  validation_method = "DNS"

  tags = {
      Name: var.domain_name
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_route53_record" "validation_record" {
  zone_id = aws_route53_zone.generic_zone.zone_id
  name    = tolist(aws_acm_certificate.certificate_request.domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.certificate_request.domain_validation_options).0.resource_record_type
  records = [tolist(aws_acm_certificate.certificate_request.domain_validation_options).0.resource_record_value]
  ttl     = 172800
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate_request.arn
  validation_record_fqdns = [aws_route53_record.validation_record.fqdn]
  
  timeouts {
    create = "5m"
  }
  
}

resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name              = "${var.domain_name}.com"
  regional_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
    depends_on = [aws_acm_certificate_validation.certificate_validation]
}

resource "aws_api_gateway_base_path_mapping" "base_path" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}

resource "aws_route53_record" "a_record" {
  name    = aws_api_gateway_domain_name.custom_domain.domain_name
  type    = "A"
  zone_id = aws_route53_zone.generic_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name = "${var.service_name}-${terraform.workspace}"
  description = "${var.service_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "things" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "things"
}

# POST
resource "aws_api_gateway_method" "create" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = "POST"
  authorization = "NONE"

  request_parameters = {
    for p in ["thing"]: "method.request.path.${p}" => true
  }
}

resource "aws_api_gateway_method_response" "response_201" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.create.http_method
  status_code = "201"
}

resource "aws_api_gateway_integration" "create" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.create.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.create_ts.lambda_function_invoke_arn
  credentials = aws_iam_role.apigw_invoke_function.arn

  request_parameters = {
    for p in ["thing"]: "integration.request.path.${p}" => "method.request.path.${p}"
  }
}

# DELETE
resource "aws_api_gateway_method" "delete" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = "DELETE"
  authorization = "NONE"

  request_parameters = {
    for p in ["thing"]: "method.request.path.${p}" => true
  }
}

resource "aws_api_gateway_method_response" "delete_202" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = "202"
}

resource "aws_api_gateway_integration" "delete" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.delete_ts.lambda_function_invoke_arn
  credentials = aws_iam_role.apigw_invoke_function.arn

  request_parameters = {
    for p in ["thing"]: "integration.request.path.${p}" => "method.request.path.${p}"
  }
}

# GET
resource "aws_api_gateway_method" "get" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = "GET"
  authorization = "NONE"

  request_parameters = {
    for p in ["thing"]: "method.request.path.${p}" => true
  }
}

resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.get_ts.lambda_function_invoke_arn
  credentials = aws_iam_role.apigw_invoke_function.arn

  request_parameters = {
    for p in ["thing"]: "integration.request.path.${p}" => "method.request.path.${p}"
  }
}

# PUT
resource "aws_api_gateway_method" "put" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = "PUT"
  authorization = "NONE"

  request_parameters = {
    for p in ["thing"]: "method.request.path.${p}" => true
  }
}

resource "aws_api_gateway_method_response" "put_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "put" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.things.id
  http_method = aws_api_gateway_method.put.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = module.put_ts.lambda_function_invoke_arn
  credentials = aws_iam_role.apigw_invoke_function.arn

  request_parameters = {
    for p in ["thing"]: "integration.request.path.${p}" => "method.request.path.${p}"
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.things.id,
      aws_api_gateway_method.create.id,
      aws_api_gateway_integration.create.id,
      aws_api_gateway_method.delete.id,
      aws_api_gateway_integration.delete.id,
      aws_api_gateway_method.get.id,
      aws_api_gateway_integration.get.id,
      aws_api_gateway_method.put.id,
      aws_api_gateway_integration.put.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name = "v1"
}