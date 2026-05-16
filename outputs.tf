output "rds_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.reports_bucket.bucket
}

output "sqs_process_url" {
  value = aws_sqs_queue.diagram_process.url
}

output "sqs_status_url" {
  value = aws_sqs_queue.status_update.url
}

output "ec2_public_ip" {
  value = aws_eip.app_eip.public_ip
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}
