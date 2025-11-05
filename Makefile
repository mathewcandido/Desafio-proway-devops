# Informações do stack e configuração da AWS
STACK_NAME = desafio-proway-devops
TEMPLATE_FILE = template.yaml
REGION = us-east-1
KEY_NAME = matheus-keypair.pem
REPO_URL = https://github.com/mathewcandido/Desafio-proway-devops
BRANCH = main

# IDs da VPC/Subnet (substituir pelos valores reais)
SUBNET_ID = subnet-07f25c27c4f87bbcf 
VPC_ID = vpc-06786ee7f7a163059


# Etapas de build e container

build:
	@echo "Instalando dependências e gerando build da aplicação..."
	yarn install
	yarn build
	@echo "Build concluído!"

docker-build:
	@echo "🐳 Construindo imagem Docker..."
	docker build -t jewelry-app .
	@echo "Imagem Docker criada com sucesso!"


# CloudFormation
create-stack:
	@echo "🚀 Iniciando criação do stack '$(STACK_NAME)'..."
	aws cloudformation create-stack \
		--stack-name $(STACK_NAME) \
		--template-body file://$(TEMPLATE_FILE) \
		--parameters \
			ParameterKey=KeyName,ParameterValue=$(KEY_NAME) \
			ParameterKey=RepoUrl,ParameterValue=$(REPO_URL) \
			ParameterKey=Branch,ParameterValue=$(BRANCH) \
			ParameterKey=SubnetId,ParameterValue=$(SUBNET_ID) \
			ParameterKey=VpcId,ParameterValue=$(VPC_ID) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--region $(REGION)

	@echo "⏳ Aguardando a conclusão da criação do stack..."
	aws cloudformation wait stack-create-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION)

	@echo "Stack '$(STACK_NAME)' criado com sucesso!"

# Utilitários
get-ip:
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--query "Stacks[0].Outputs[?OutputKey=='PublicIP'].OutputValue" \
		--output text \
		--region $(REGION)

# ---------------------------
# Deploy
deploy: create-stack
	@echo "⏳ Aguardando inicialização da instância..."
	@echo "A aplicação será provisionada automaticamente via Docker Compose (UserData)."
	@IP=$$(make get-ip); \
	echo "Deploy concluído com sucesso! Acesse: http://$$IP"

# ---------------------------
# Limpeza
delete-stack:
	@echo "🧹 Removendo stack '$(STACK_NAME)'..."
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--region $(REGION)

	@echo "⏳ Aguardando remoção completa..."
	aws cloudformation wait stack-delete-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION)

	@echo "Stack removido com sucesso!"
