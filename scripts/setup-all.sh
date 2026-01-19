#!/bin/bash

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para printar mensagens coloridas
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Banner
echo ""
echo "========================================="
echo "  Desafio DevOps - Setup Completo"
echo "========================================="
echo ""

# 1. Verificar pré-requisitos
print_info "Verificando pré-requisitos..."

MISSING_DEPS=0

if ! command_exists docker; then
    print_error "Docker não encontrado. Instale: https://docs.docker.com/get-docker/"
    MISSING_DEPS=1
fi

if ! command_exists kubectl; then
    print_error "kubectl não encontrado. Instale: https://kubernetes.io/docs/tasks/tools/"
    MISSING_DEPS=1
fi

if ! command_exists k3d; then
    print_error "k3d não encontrado. Instale: https://k3d.io/#installation"
    MISSING_DEPS=1
fi

if ! command_exists terraform; then
    print_error "Terraform não encontrado. Instale: https://www.terraform.io/downloads"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Instale as dependências faltantes e execute novamente."
    exit 1
fi

print_success "Todos os pré-requisitos instalados!"
echo ""

# 2. Mostrar versões
print_info "Versões instaladas:"
echo "  Docker:     $(docker --version)"
echo "  kubectl:    $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "  k3d:        $(k3d version)"
echo "  Terraform:  $(terraform version | head -n1)"
echo ""

# 3. Criar infraestrutura com Terraform
print_info "Criando clusters k3d com Terraform..."
cd terraform

if [ ! -d ".terraform" ]; then
    print_info "Inicializando Terraform..."
    terraform init
fi

print_info "Aplicando configuração Terraform..."
terraform apply -auto-approve

if [ $? -ne 0 ]; then
    print_error "Erro ao criar infraestrutura com Terraform"
    exit 1
fi

cd ..
print_success "Clusters k3d criados com sucesso!"
echo ""

# 4. Aguardar clusters ficarem prontos
print_info "Aguardando clusters ficarem prontos..."
sleep 5

# 5. Verificar clusters
print_info "Verificando clusters criados..."
k3d cluster list
echo ""

# 6. Build das imagens Docker
print_info "Construindo imagens Docker..."
./scripts/build-images.sh

if [ $? -ne 0 ]; then
    print_error "Erro ao construir imagens Docker"
    exit 1
fi

print_success "Imagens Docker construídas!"
echo ""

# 7. Deploy no ambiente DEV
print_info "Fazendo deploy no ambiente DEV..."
./scripts/deploy-dev.sh

if [ $? -ne 0 ]; then
    print_error "Erro ao fazer deploy no DEV"
    exit 1
fi

print_success "Deploy DEV concluído!"
echo ""

# 8. Deploy no ambiente PROD
print_info "Fazendo deploy no ambiente PROD..."
./scripts/deploy-prod.sh

if [ $? -ne 0 ]; then
    print_error "Erro ao fazer deploy no PROD"
    exit 1
fi

print_success "Deploy PROD concluído!"
echo ""

# 9. Verificar status final
print_info "Verificando status final..."
echo ""

echo "Cluster DEV:"
kubectl get pods --context k3d-desafio-dev
echo ""

echo "Cluster PROD:"
kubectl get pods --context k3d-desafio-prod
echo ""

# 10. Teste de conectividade
print_info "Testando conectividade..."
echo ""

print_info "Testando Backend DEV..."
if curl -s http://localhost:30001/health > /dev/null; then
    print_success "Backend DEV: OK"
else
    print_warning "Backend DEV: Não acessível (pode levar alguns segundos para ficar pronto)"
fi

print_info "Testando Backend PROD..."
if curl -s http://localhost:30101/health > /dev/null; then
    print_success "Backend PROD: OK"
else
    print_warning "Backend PROD: Não acessível (pode levar alguns segundos para ficar pronto)"
fi

print_info "Testando Frontend DEV..."
if curl -s http://localhost:30002 > /dev/null; then
    print_success "Frontend DEV: OK"
else
    print_warning "Frontend DEV: Não acessível (pode levar alguns segundos para ficar pronto)"
fi

print_info "Testando Frontend PROD..."
if curl -s http://localhost:30102 > /dev/null; then
    print_success "Frontend PROD: OK"
else
    print_warning "Frontend PROD: Não acessível (pode levar alguns segundos para ficar pronto)"
fi

echo ""

# 11. Resumo final
echo "========================================="
echo "         SETUP CONCLUÍDO!"
echo "========================================="
echo ""
echo "Ambiente DEV:"
echo "  Frontend: ${GREEN}http://localhost:30002${NC}"
echo "  Backend:  ${GREEN}http://localhost:30001${NC}"
echo "  Context:  k3d-desafio-dev"
echo ""
echo "Ambiente PROD:"
echo "  Frontend: ${GREEN}http://localhost:30102${NC}"
echo "  Backend:  ${GREEN}http://localhost:30101${NC}"
echo "  Context:  k3d-desafio-prod"
echo ""
echo "Comandos úteis:"
echo "  make status         - Ver status dos clusters"
echo "  make clean          - Limpar deployments"
echo "  make destroy        - Destruir infraestrutura"
echo ""
echo "  kubectl get pods --context k3d-desafio-dev"
echo "  kubectl get pods --context k3d-desafio-prod"
echo ""
echo "Consulte o README.md para mais informações!"
echo "========================================="
echo ""
