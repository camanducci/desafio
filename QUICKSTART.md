# Quick Start Guide

Guia rápido para executar o projeto em 3 passos.

## Pré-requisitos

Instale as ferramentas necessárias:

```bash
# Verificar se as ferramentas estão instaladas
docker --version
kubectl version --client
k3d version
terraform version
```

Se alguma ferramenta não estiver instalada:
- Docker: https://docs.docker.com/get-docker/
- kubectl: https://kubernetes.io/docs/tasks/tools/
- k3d: https://k3d.io/#installation
- Terraform: https://www.terraform.io/downloads

## Opção 1: Usando Makefile (Recomendado)

### Deploy completo (tudo de uma vez):

```bash
make all
```

Este comando vai:
1. Criar a infraestrutura (clusters k3d)
2. Build das imagens Docker
3. Deploy no ambiente DEV
4. Deploy no ambiente PROD

### Deploy por etapas:

```bash
# 1. Criar infraestrutura
make init

# 2. Build das imagens
make build

# 3. Deploy no DEV
make deploy-dev

# 4. Deploy no PROD (opcional)
make deploy-prod

# 5. Ver status
make status
```

## Opção 2: Usando Scripts

```bash
# 1. Criar infraestrutura
cd terraform
terraform init
terraform apply
cd ..

# 2. Build das imagens
./scripts/build-images.sh

# 3. Deploy no DEV
./scripts/deploy-dev.sh

# 4. Deploy no PROD (opcional)
./scripts/deploy-prod.sh
```

## Acessar as Aplicações

### Ambiente DEV
- Frontend: http://localhost:30002
- Backend: http://localhost:30001
- API Dados: http://localhost:30001/dados

### Ambiente PROD
- Frontend: http://localhost:30102
- Backend: http://localhost:30101
- API Dados: http://localhost:30101/dados

## Comandos Úteis

```bash
# Ver todos os comandos disponíveis
make help

# Ver status dos clusters
make status

# Alternar entre ambientes
kubectl config use-context k3d-desafio-dev
kubectl config use-context k3d-desafio-prod

# Ver pods
kubectl get pods

# Ver logs
kubectl logs -l app=backend
kubectl logs -l app=frontend
```

## Limpeza

```bash
# Limpar recursos Kubernetes
make clean

# Destruir toda infraestrutura
make destroy
```

## Troubleshooting

### Porta já em uso
```bash
# Verificar o que está usando a porta
lsof -i :30001

# Ou destruir e recriar
make destroy
make all
```

### Pods não iniciam
```bash
# Ver detalhes do pod
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Reimportar imagens
```bash
k3d image import backend-dummy:latest -c desafio-dev
k3d image import frontend-dummy:latest -c desafio-dev
```

## Próximos Passos

Consulte o [README.md](README.md) completo para:
- Arquitetura detalhada
- Todos os comandos disponíveis
- Decisões de arquitetura
- Melhorias futuras
