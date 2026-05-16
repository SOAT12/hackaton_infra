resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "reports_bucket" {
  bucket        = "hackaton-reports-soat-${random_string.suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.reports_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.reports_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.reports_bucket.arn}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}
