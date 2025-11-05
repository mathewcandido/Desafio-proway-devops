#!/bin/bash
set -e

# -----------------------------
# Script para rodar o Makefile completo
# -----------------------------

echo "Build da aplicação..."
make build

echo "Construir imagem Docker..."
make docker-build

echo "Criar stack CloudFormation..."
make create-stack

echo "Aguardando inicialização da instância..."
IP=$(make get-ip)
echo "Deploy concluído! Acesse a aplicação em: http://$IP"
