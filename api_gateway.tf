resource "aws_apigatewayv2_api" "http_api" {
  name          = "hackaton-gateway"
  protocol_type = "HTTP"
}

# ==========================================
# 1. Rota Principal -> Diagram API (Porta 8080)
# ==========================================
resource "aws_apigatewayv2_integration" "diagram_api" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_eip.app_eip.public_ip}:8080/{proxy}"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.diagram_api.id}"
}

# ==========================================
# 2. Rota Específica -> Report API (Porta 8081)
# ==========================================
resource "aws_apigatewayv2_integration" "report_api_proxy" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_eip.app_eip.public_ip}:8081/api/reports/{proxy}"
  integration_method = "ANY"
}
resource "aws_apigatewayv2_route" "report_route_proxy" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /api/reports/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.report_api_proxy.id}"
}

resource "aws_apigatewayv2_integration" "report_api_exact" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_eip.app_eip.public_ip}:8081/api/reports"
  integration_method = "ANY"
}
resource "aws_apigatewayv2_route" "report_route_exact" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /api/reports"
  target    = "integrations/${aws_apigatewayv2_integration.report_api_exact.id}"
}

# ==========================================
# STAGE
# ==========================================
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}