resource "aws_ecr_repository" "diagram_api" {
  name                 = "hackaton-diagram-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Facilita a destruição no final
}

resource "aws_ecr_repository" "report_api" {
  name                 = "hackaton-report-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
