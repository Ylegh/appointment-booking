resource "aws_api_gateway_rest_api" "appointment_api" {
  name        = "appointment-api"
  description = "Proxy to handle requests to the Appointment API"
}
resource "aws_api_gateway_resource" "appointment_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.appointment_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.appointment_api.root_resource_id}"
  path_part   = "appointment"
}
resource "aws_api_gateway_method" "appointment_api_post" {
  rest_api_id        = "${aws_api_gateway_rest_api.appointment_api.id}"
  resource_id        = "${aws_api_gateway_resource.appointment_api_resource.id}"
  http_method        = "POST"
  authorization      = "NONE"
}

resource "aws_api_gateway_method" "appointment_api_get" {
  rest_api_id        = "${aws_api_gateway_rest_api.appointment_api.id}"
  resource_id        = "${aws_api_gateway_resource.appointment_api_resource.id}"
  http_method        = "GET"
  authorization      = "NONE"
}
resource "aws_api_gateway_integration" "appointment_api_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.appointment_api.id
  resource_id             = aws_api_gateway_resource.appointment_api_resource.id
  http_method             = aws_api_gateway_method.appointment_api_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.appointment_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "appointment_api_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.appointment_api.id
  resource_id             = aws_api_gateway_resource.appointment_api_resource.id
  http_method             = aws_api_gateway_method.appointment_api_get.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.appointment_lambda.invoke_arn
}
resource "aws_lambda_permission" "appointment_api_lambda_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.appointment_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:eu-west-2:000000000000:${aws_api_gateway_rest_api.appointment_api.id}/*"
}
resource "aws_api_gateway_deployment" "appointment_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.appointment_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "appointment_api_stage" {
  deployment_id = aws_api_gateway_deployment.appointment_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.appointment_api.id
  stage_name    = "dev"
}