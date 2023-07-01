// rest_api is the container for all of the other api gateway
// resource objects
resource "aws_api_gateway_rest_api" "os-config-api-gateway" {
  name        = "os-config-api-gateway"
  description = "os-config-api-gateway"
}

// api resources
resource "aws_api_gateway_resource" "os-config-proxy" {
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.os-config-api-gateway.id
  parent_id   = aws_api_gateway_rest_api.os-config-api-gateway.root_resource_id
}

resource "aws_api_gateway_method" "os-config-proxy" {
  rest_api_id   = aws_api_gateway_rest_api.os-config-api-gateway.id
  resource_id   = aws_api_gateway_resource.os-config-proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "os-config-lambda-integration" {
  rest_api_id = aws_api_gateway_rest_api.os-config-api-gateway.id
  resource_id = aws_api_gateway_method.os-config-proxy-root.resource_id
  http_method = aws_api_gateway_method.os-config-proxy-root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.os-config-lamba-1.invoke_arn
}

resource "aws_api_gateway_method" "os-config-proxy-root" {
  rest_api_id   = aws_api_gateway_rest_api.os-config-api-gateway.id
  resource_id   = aws_api_gateway_rest_api.os-config-api-gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "os-config-lambda-root" {
  rest_api_id = aws_api_gateway_rest_api.os-config-api-gateway.id
  resource_id = aws_api_gateway_method.os-config-proxy.resource_id
  http_method = aws_api_gateway_method.os-config-proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.os-config-lamba-1.invoke_arn
}

resource "aws_api_gateway_deployment" "os-config-api-gateway-deployment" {
  depends_on = [
    aws_api_gateway_integration.os-config-lambda-integration,
    aws_api_gateway_integration.os-config-lambda-root,
  ]

  rest_api_id = aws_api_gateway_rest_api.os-config-api-gateway.id
  stage_name  = "os-config-test"
}

resource "aws_lambda_permission" "os-config-apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.os-config-lamba-1.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.os-config-api-gateway.execution_arn}/*/*"
}

output "base_url" {
  value = aws_api_gateway_deployment.os-config-api-gateway-deployment.invoke_url
}
