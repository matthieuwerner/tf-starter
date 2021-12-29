
// S3 deployment
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-${terraform.workspace}"

  acl           = "private"
  force_destroy = true
}

// Package application
data "archive_file" "lambda_application" {
  type        = "zip"
  source_dir  = "${path.module}/../../application"
  output_path = "${path.module}/.build/${var.project_name}.zip"

}

resource "aws_s3_bucket_object" "lambda_application" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${var.project_name}.zip"
  source = data.archive_file.lambda_application.output_path
  etag   = filemd5(data.archive_file.lambda_application.output_path)
}

// Lambda function definition
resource "aws_lambda_function" "application" {
  function_name = var.project_name

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_application.key

  runtime     = "provided.al2"
  layers      = [var.php_layer]
  handler     = var.entrypoint
  memory_size = 1024
  timeout     = 28

  source_code_hash = data.archive_file.lambda_application.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = var.env
  }
}

resource "aws_cloudwatch_log_group" "application" {
  name = "/aws/lambda/${aws_lambda_function.application.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Api gateway
resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "application" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.application.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "application" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.application.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.application.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
