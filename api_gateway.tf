resource "aws_apigatewayv2_api" "http_api" {
  name          = "hackaton-gateway"
  protocol_type = "HTTP"
}

# ==========================================
# 1. DIAGRAM API (Porta 8080)
# ==========================================
resource "aws_apigatewayv2_integration" "diagram_api" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_instance.app_server.public_ip}:8080"
  integration_method = "ANY"
}

# Rota padrão ($default): Tudo o que não casar com as regras abaixo vai para a Diagram API
# Isso significa que o /actuator, /actuator/health e /v1/diagrams da Diagram API funcionam aqui nativamente!
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.diagram_api.id}"
}

# ==========================================
# 2. REPORT API - Rotas de Negócio (Porta 8081)
# ==========================================
resource "aws_apigatewayv2_integration" "report_api" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_instance.app_server.public_ip}:8081"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_route" "report_route_proxy" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /api/reports/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.report_api.id}"
}

resource "aws_apigatewayv2_route" "report_route_exact" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /api/reports"
  target    = "integrations/${aws_apigatewayv2_integration.report_api.id}"
}

# ==========================================
# 3. REPORT API - Mapeamento do Actuator (Porta 8081)
# ==========================================

# Rota para a Raiz (/reports-actuator)
resource "aws_apigatewayv2_integration" "report_actuator_root" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_instance.app_server.public_ip}:8081/actuator"
  integration_method = "GET"
}
resource "aws_apigatewayv2_route" "report_actuator_root_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /reports-actuator"
  target    = "integrations/${aws_apigatewayv2_integration.report_actuator_root.id}"
}

# Rota para a Saúde (/reports-actuator/health)
resource "aws_apigatewayv2_integration" "report_actuator_health" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_instance.app_server.public_ip}:8081/actuator/health"
  integration_method = "GET"
}
resource "aws_apigatewayv2_route" "report_actuator_health_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /reports-actuator/health"
  target    = "integrations/${aws_apigatewayv2_integration.report_actuator_health.id}"
}

# Rota para Informações (/reports-actuator/info)
resource "aws_apigatewayv2_integration" "report_actuator_info" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_instance.app_server.public_ip}:8081/actuator/info"
  integration_method = "GET"
}
resource "aws_apigatewayv2_route" "report_actuator_info_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /reports-actuator/info"
  target    = "integrations/${aws_apigatewayv2_integration.report_actuator_info.id}"
}

# Rota para Métricas (/reports-actuator/metrics)
resource "aws_apigatewayv2_integration" "report_actuator_metrics" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_instance.app_server.public_ip}:8081/actuator/metrics"
  integration_method = "GET"
}
resource "aws_apigatewayv2_route" "report_actuator_metrics_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /reports-actuator/metrics"
  target    = "integrations/${aws_apigatewayv2_integration.report_actuator_metrics.id}"
}

# ==========================================
# STAGE
# ==========================================
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}