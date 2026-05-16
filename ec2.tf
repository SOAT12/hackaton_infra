resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "hackaton_app_sg"
  description = "Permitir HTTP e SSH"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Descomente a linha abaixo caso a sua aplicação dentro da EC2 precise assumir
  # a role do lab para ler/escrever no S3 ou SQS sem as chaves nas variáveis de ambiente.
  # iam_instance_profile = "LabInstanceProfile"

  user_data = templatefile("${path.module}/scripts/setup_docker.sh", {
    db_url          = "jdbc:postgresql://${aws_db_instance.postgres_db.endpoint}/${aws_db_instance.postgres_db.db_name}"
    db_username     = var.db_username
    db_password     = var.db_password
    sqs_process_url = aws_sqs_queue.diagram_process.url
    sqs_status_url  = aws_sqs_queue.status_update.url
    s3_bucket_name  = aws_s3_bucket.reports_bucket.bucket
    aws_region      = var.aws_region
  })

  tags = {
    Name = "Hackaton-App-Host"
  }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"
}
