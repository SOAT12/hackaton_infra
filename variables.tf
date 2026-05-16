variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "Utilizador do banco de dados RDS"
  type        = string
  default     = "diagram_api"
}

variable "db_password" {
  description = "Password do banco de dados RDS"
  type        = string
  default     = "diagramdbpass"
  sensitive   = true
}
