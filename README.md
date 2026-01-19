# Desafio DevOps - Infraestrutura com Docker, Kubernetes e Terraform

Solução completa de infraestrutura e deploy de aplicações dummy utilizando Docker, Kubernetes (k3d) e Terraform.

## Visão Geral

Este projeto implementa:
- **Backend Dummy**: API REST mínima em Node.js/Express
- **Frontend Dummy**: Interface web que consome a API backend
- **Containerização**: Docker para ambas as aplicações
- **Orquestração**: Kubernetes local via k3d
- **Infraestrutura como Código**: Terraform para gerenciar clusters
- **Dois ambientes**: `dev` e `prod` com clusters k3d separados

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                      Ambiente DEV                            │
│  ┌──────────────────────┐      ┌──────────────────────┐    │
│  │   Frontend (2 pods)  │──────│  Backend (2 pods)    │    │
│  │   NodePort: 30002    │      │  NodePort: 30001     │    │
│  └──────────────────────┘      └──────────────────────┘    │
│            k3d-desafio-dev                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      Ambiente PROD                           │
│  ┌──────────────────────┐      ┌──────────────────────┐    │
│  │   Frontend (3 pods)  │──────│  Backend (3 pods)    │    │
│  │   NodePort: 30102    │      │  NodePort: 30101     │    │
│  └──────────────────────┘      └──────────────────────┘    │
│            k3d-desafio-prod                                  │
└─────────────────────────────────────────────────────────────┘
```

## Estrutura do Projeto

```
desafio/
├── backend/
│   ├── Dockerfile              # Imagem Docker do backend
│   ├── package.json            # Dependências Node.js
│   ├── index.js                # Código da API REST
│   └── .dockerignore
├── frontend/
│   ├── Dockerfile              # Imagem Docker do frontend
│   ├── index.html              # Interface web
│   └── nginx.conf              # Configuração nginx
├── terraform/
│   ├── main.tf                 # Definição dos clusters k3d
│   ├── variables.tf            # Variáveis do Terraform
│   └── outputs.tf              # Outputs de acesso
├── k8s/
│   ├── dev/                    # Manifests para DEV
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   └── frontend-service.yaml
│   └── prod/                   # Manifests para PROD
│       ├── backend-deployment.yaml
│       ├── backend-service.yaml
│       ├── frontend-deployment.yaml
│       └── frontend-service.yaml
├── scripts/
│   ├── build-images.sh         # Build das imagens Docker
│   ├── deploy-dev.sh           # Deploy no ambiente DEV
│   ├── deploy-prod.sh          # Deploy no ambiente PROD
│   └── cleanup.sh              # Limpeza completa
└── README.md
```

## Pré-requisitos

Ferramentas necessárias instaladas:

- [Docker](https://docs.docker.com/get-docker/) (>= 20.10)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (>= 1.25)
- [k3d](https://k3d.io/#installation) (>= 5.0)
- [Terraform](https://www.terraform.io/downloads) (>= 1.5)

### Verificar instalações:

```bash
docker --version
kubectl version --client
k3d version
terraform version
```

## Como Usar

### 1. Criar a Infraestrutura

Use o Terraform para criar os clusters k3d:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Isso criará:
- Cluster `desafio-dev` (1 server + 1 agent)
- Cluster `desafio-prod` (1 server + 2 agents)
- Configurações de portas NodePort

**Saída esperada:**
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

dev_access_info = {
  "backend_url" = "http://localhost:30001"
  "frontend_url" = "http://localhost:30002"
  "kubectl_context" = "k3d-desafio-dev"
}
prod_access_info = {
  "backend_url" = "http://localhost:30101"
  "frontend_url" = "http://localhost:30102"
  "kubectl_context" = "k3d-desafio-prod"
}
```

### 2. Build das Imagens Docker

Construa as imagens Docker do backend e frontend:

```bash
cd ..
./scripts/build-images.sh
```

Isso criará:
- `backend-dummy:latest`
- `frontend-dummy:latest`

### 3. Deploy no Ambiente DEV

```bash
./scripts/deploy-dev.sh
```

Este script:
1. Importa as imagens para o cluster k3d dev
2. Aplica os manifests Kubernetes
3. Aguarda os pods ficarem prontos
4. Exibe as URLs de acesso

**Acesso ao DEV:**
- Frontend: http://localhost:30002
- Backend API: http://localhost:30001
- Health check: http://localhost:30001/health
- Dados: http://localhost:30001/dados

### 4. Deploy no Ambiente PROD

```bash
./scripts/deploy-prod.sh
```

**Acesso ao PROD:**
- Frontend: http://localhost:30102
- Backend API: http://localhost:30101
- Health check: http://localhost:30101/health
- Dados: http://localhost:30101/dados

## Comandos Úteis

### Gerenciar Clusters

```bash
# Listar clusters
k3d cluster list

# Parar cluster
k3d cluster stop desafio-dev
k3d cluster stop desafio-prod

# Iniciar cluster
k3d cluster start desafio-dev
k3d cluster start desafio-prod
```

### Gerenciar Kubernetes

```bash
# Alternar entre ambientes
kubectl config use-context k3d-desafio-dev
kubectl config use-context k3d-desafio-prod

# Ver pods
kubectl get pods

# Ver services
kubectl get services

# Ver logs
kubectl logs -l app=backend
kubectl logs -l app=frontend

# Descrever recursos
kubectl describe deployment backend
kubectl describe service frontend

# Port-forward (alternativa ao NodePort)
kubectl port-forward svc/backend 8080:3000
kubectl port-forward svc/frontend 8081:80
```

### Debug

```bash
# Ver eventos
kubectl get events --sort-by='.lastTimestamp'

# Entrar em um pod
kubectl exec -it <pod-name> -- /bin/sh

# Ver recursos do cluster
kubectl top nodes
kubectl top pods
```

## Endpoints da API

### Backend

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/` | GET | Informações da API |
| `/health` | GET | Health check |
| `/dados` | GET | Retorna dados dummy |

### Exemplo de resposta `/dados`:

```json
{
  "message": "Dados do backend dummy",
  "environment": "dev",
  "data": {
    "usuarios": [
      { "id": 1, "nome": "João Silva", "email": "joao@example.com" },
      { "id": 2, "nome": "Maria Santos", "email": "maria@example.com" },
      { "id": 3, "nome": "Pedro Oliveira", "email": "pedro@example.com" }
    ],
    "produtos": [
      { "id": 1, "nome": "Produto A", "preco": 100.00 },
      { "id": 2, "nome": "Produto B", "preco": 200.00 },
      { "id": 3, "nome": "Produto C", "preco": 300.00 }
    ]
  },
  "timestamp": "2025-01-18T12:00:00.000Z"
}
```

## Diferenças entre DEV e PROD

| Aspecto | DEV | PROD |
|---------|-----|------|
| **Réplicas Backend** | 2 | 3 |
| **Réplicas Frontend** | 2 | 3 |
| **Nodes do cluster** | 1 server + 1 agent | 1 server + 2 agents |
| **Recursos (Backend)** | 64-128Mi / 100-200m CPU | 128-256Mi / 200-500m CPU |
| **Recursos (Frontend)** | 32-64Mi / 50-100m CPU | 64-128Mi / 100-200m CPU |
| **Backend Port** | 30001 | 30101 |
| **Frontend Port** | 30002 | 30102 |
| **Environment Variable** | `ENVIRONMENT=dev` | `ENVIRONMENT=prod` |

## Limpeza

Para destruir toda a infraestrutura:

```bash
./scripts/cleanup.sh
```

Ou manualmente:

```bash
cd terraform
terraform destroy -auto-approve
```

## Decisões de Arquitetura

### 1. Separação de Clusters
- Optei por **clusters separados** (dev e prod) ao invés de namespaces
- Proporciona isolamento total entre ambientes
- Simula melhor cenários reais onde dev e prod são completamente separados

### 2. Uso de k3d
- k3d é uma distribuição leve do Kubernetes
- Ideal para desenvolvimento local e testes
- Rápido para criar e destruir clusters

### 3. NodePort vs LoadBalancer
- Usei **NodePort** para facilitar acesso local
- Portas fixas facilitam testes e automação
- Em produção real, usaria Ingress Controller ou LoadBalancer

### 4. Imagens Docker
- Imagens simples e otimizadas (Alpine Linux)
- `imagePullPolicy: Never` para usar imagens locais
- Em produção real, usaria registry (Docker Hub, ECR, GCR)

### 5. Aplicações Dummy
- Backend: Node.js/Express (leve e rápido)
- Frontend: HTML + Vanilla JS (sem frameworks desnecessários)
- Foco na infraestrutura, não na aplicação

### 6. Health Checks
- Probes de liveness e readiness configurados
- Garantem que Kubernetes só roteia tráfego para pods saudáveis
- Reinicialização automática em caso de falha

### 7. Recursos (CPU/Memory)
- Requests e limits definidos
- Ambiente PROD tem mais recursos que DEV
- Previne que um pod consuma todos os recursos do node

### 8. Scripts de Automação
- Scripts bash facilitam operações comuns
- Reduzem chance de erros em comandos complexos
- Documentam o processo de deploy

### 9. Terraform Provider k3d
- Infraestrutura como código para os clusters
- Versionamento e reprodutibilidade
- Facilita criação de múltiplos ambientes

## Melhorias Futuras

Para um ambiente de produção real, consideraria:

1. **CI/CD Pipeline**: GitHub Actions, GitLab CI ou Jenkins
2. **Registry de Imagens**: Docker Hub privado ou cloud registry
3. **Ingress Controller**: Nginx Ingress ou Traefik
4. **Monitoramento**: Prometheus + Grafana
5. **Logs Centralizados**: ELK Stack ou Loki
6. **Secrets Management**: Kubernetes Secrets ou Vault
7. **Helm Charts**: Gerenciamento de releases
8. **Testes Automatizados**: Jest, Cypress, k6
9. **GitOps**: ArgoCD ou Flux
10. **Service Mesh**: Istio ou Linkerd

## Troubleshooting

### Problema: Pods não iniciam

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Problema: Imagens não encontradas

Reimporte as imagens:
```bash
k3d image import backend-dummy:latest -c desafio-dev
k3d image import frontend-dummy:latest -c desafio-dev
```

### Problema: Porta já em uso

Verifique processos usando as portas:
```bash
lsof -i :30001
lsof -i :30002
```

### Problema: Cluster não responde

Reinicie o cluster:
```bash
k3d cluster stop desafio-dev
k3d cluster start desafio-dev
```

## Conclusão

Este projeto demonstra uma stack completa de DevOps com:
- Containerização de aplicações
- Orquestração com Kubernetes
- Infraestrutura como código com Terraform
- Separação de ambientes
- Automação de deploy
- Boas práticas de configuração

Pronto para ser usado como base para projetos reais ou como material de estudo.
