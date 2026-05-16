#!/bin/bash
# Atualizar repositórios e pacotes
apt-get update -y

# Instalar Docker, Compose e utilitários
apt-get install -y docker.io docker-compose curl unzip

# Configurar serviços do Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Instalar AWS CLI para testes de integração no servidor
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Gravar variaveis injetadas pelo Terraform no ficheiro .env da maquina
cat <<EOF > /home/ubuntu/.env
DB_URL=${db_url}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}
SQS_PROCESS_URL=${sqs_process_url}
SQS_STATUS_URL=${sqs_status_url}
S3_BUCKET_NAME=${s3_bucket_name}
AWS_REGION=${aws_region}
EOF

# Ajustar permissões do ficheiro para segurança
chown ubuntu:ubuntu /home/ubuntu/.env
chmod 600 /home/ubuntu/.env

# Criar rede Docker para comunicação interna (Resolução de nomes DNS)
docker network create hackaton_net || true

# Iniciar o MongoDB
docker run -d --name mongodb --net hackaton_net --restart always -p 27017:27017 -v mongo_data:/data/db mongo:latest

