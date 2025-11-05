#!/bin/bash
set -e

# Instalação de dependências (Alpine)
sudo apt update

# Instala Node.js, npm, make e Docker
sudo apt install -y nodejs npm make docker.io

# Instala yarn globalmente
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
