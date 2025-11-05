🚀 Tecnologias

Vue.js 3
 — Framework frontend

Docker
 — Containerização

AWS CloudFormation
 — Infraestrutura como código

Makefile
 — Automação de comandos

⚙️ Pré-requisitos

Antes de começar, garanta que você tenha instalado:
*Para testes locais*
Node.js 18+
Docker


🧩 Execução Local
🔧 Modo Desenvolvimento
# Instalar dependências
yarn install

# Executar o servidor de desenvolvimento
yarn dev


Acesse em: http://localhost:5173

🐳 Usando Docker
# Via Makefile
make docker-run

# Ou manualmente
docker compose up -d


Acesse em: http://localhost:8080

☁️ Deploy na AWS
Passo a passo

Clone o repositório dentro do seu CLI

git clone https://github.com/mathewcandido/Desafio-proway-devops.git
cd Desafio-proway-devops

Crie uma key pair

aws ec2 create-key-pair --key-name matheus-keypair --query "KeyMaterial" --output text > matheus-keypair.pem
chmod 400 matheus-keypair.pem


💡 Você pode alterar o nome da key pair. Apenas lembre-se de atualizar o nome no arquivo Makefile.

Execute cp -r <sua-keypair> ./Desafio-proway-devops 

Execute o script de deploy

./run-me.sh


Após a execução, o terminal exibirá o IP público da instância.
Acesse:

http://<SEU-IP>:8000


🧠 Sobre o Projeto

Este projeto foi desenvolvido como parte do Desafio Proway DevOps, com foco em:

Provisionamento de uma aplicação que estaria em outra cloud - Azure

Deploy automatizado na AWS usando CloudFormation;

Automação via Makefile e scripts Shell;

Uso de boas práticas de DevOps.
