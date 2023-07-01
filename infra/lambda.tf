// LAMBDA FUNCTIONS
resource "aws_lambda_function" "os-config-lamba-1" {
  function_name = "os_config_initialise"
  runtime       = "python3.10"
  role          = aws_iam_role.os-config-lambda.arn
  filename      = "../test_lambda/lambda_function_payload.zip"
  handler       = "initial_lambda.handler"
}
