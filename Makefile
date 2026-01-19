.PHONY: help init build deploy-dev deploy-prod destroy clean status

help:
	@echo "========================================="
	@echo "Desafio DevOps - Comandos Disponíveis"
	@echo "========================================="
	@echo ""
	@echo "  make init         - Inicializar infraestrutura (Terraform)"
	@echo "  make build        - Build das imagens Docker"
	@echo "  make deploy-dev   - Deploy no ambiente DEV"
	@echo "  make deploy-prod  - Deploy no ambiente PROD"
	@echo "  make all          - Executar tudo (init + build + deploy-dev + deploy-prod)"
	@echo "  make status       - Ver status dos clusters"
	@echo "  make clean        - Limpar recursos Kubernetes"
	@echo "  make destroy      - Destruir toda a infraestrutura"
	@echo ""

init:
	@echo "Inicializando infraestrutura com Terraform..."
	cd terraform && terraform init && terraform apply -auto-approve

build:
	@echo "Building Docker images..."
	./scripts/build-images.sh

deploy-dev: build
	@echo "Deploying to DEV..."
	./scripts/deploy-dev.sh

deploy-prod: build
	@echo "Deploying to PROD..."
	./scripts/deploy-prod.sh

all: init build deploy-dev deploy-prod
	@echo ""
	@echo "========================================="
	@echo "Tudo pronto!"
	@echo "========================================="
	@echo "DEV  - Frontend: http://localhost:30002"
	@echo "DEV  - Backend:  http://localhost:30001"
	@echo "PROD - Frontend: http://localhost:30102"
	@echo "PROD - Backend:  http://localhost:30101"
	@echo "========================================="

status:
	@echo "========================================="
	@echo "Status dos Clusters"
	@echo "========================================="
	@k3d cluster list
	@echo ""
	@echo "DEV Pods:"
	@kubectl get pods --context k3d-desafio-dev 2>/dev/null || echo "Cluster dev não encontrado"
	@echo ""
	@echo "PROD Pods:"
	@kubectl get pods --context k3d-desafio-prod 2>/dev/null || echo "Cluster prod não encontrado"

clean:
	@echo "Limpando recursos Kubernetes..."
	-kubectl delete -f k8s/dev/ --context k3d-desafio-dev 2>/dev/null
	-kubectl delete -f k8s/prod/ --context k3d-desafio-prod 2>/dev/null

destroy:
	@echo "Destruindo infraestrutura..."
	./scripts/cleanup.sh
