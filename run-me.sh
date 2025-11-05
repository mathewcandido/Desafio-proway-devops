#!/bin/bash
set -e

sudo yum update -y
sudo yum install -y nodejs npm make docker
sudo npm install -g yarn

echo "Build da aplicação..."
make build

echo "Construir imagem Docker..."
make docker-build

echo "Criar stack CloudFormation..."
make create-stack

echo "Aguardando inicialização da instância..."
IP=$(make get-ip)
echo "Deploy concluído! Acesse a aplicação em: http://$IP:8000"
