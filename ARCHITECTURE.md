# Arquitetura do Projeto

## Visão Geral da Infraestrutura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           HOST MACHINE                                   │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐│
│  │                    TERRAFORM PROVIDER (k3d)                        ││
│  │                                                                    ││
│  │  Gerencia criação e configuração dos clusters k3d                 ││
│  └────────────────────────────────────────────────────────────────────┘│
│                              │                                           │
│              ┌───────────────┴───────────────┐                          │
│              │                               │                          │
│              ▼                               ▼                          │
│  ┌─────────────────────┐         ┌─────────────────────┐              │
│  │  Cluster DEV        │         │  Cluster PROD       │              │
│  │  (k3d-desafio-dev)  │         │  (k3d-desafio-prod) │              │
│  │                     │         │                     │              │
│  │  Nodes:             │         │  Nodes:             │              │
│  │  - 1 Server         │         │  - 1 Server         │              │
│  │  - 1 Agent          │         │  - 2 Agents         │              │
│  └─────────────────────┘         └─────────────────────┘              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Cluster DEV - Detalhamento

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        k3d-desafio-dev                                    │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐│
│  │                    Kubernetes Namespace: default                    ││
│  │                                                                     ││
│  │  ┌──────────────────────────┐    ┌──────────────────────────┐     ││
│  │  │  Frontend Deployment     │    │  Backend Deployment      │     ││
│  │  │  Replicas: 2             │    │  Replicas: 2             │     ││
│  │  │                          │    │                          │     ││
│  │  │  ┌────────────────────┐  │    │  ┌────────────────────┐  │     ││
│  │  │  │ Pod 1              │  │    │  │ Pod 1              │  │     ││
│  │  │  │ frontend:latest    │  │    │  │ backend:latest     │  │     ││
│  │  │  │ Port: 80           │  │    │  │ Port: 3000         │  │     ││
│  │  │  │ Nginx              │  │    │  │ Node.js/Express    │  │     ││
│  │  │  │                    │  │    │  │                    │  │     ││
│  │  │  │ Resources:         │  │    │  │ Resources:         │  │     ││
│  │  │  │ - CPU: 50-100m     │  │    │  │ - CPU: 100-200m    │  │     ││
│  │  │  │ - Mem: 32-64Mi     │  │    │  │ - Mem: 64-128Mi    │  │     ││
│  │  │  └────────────────────┘  │    │  └────────────────────┘  │     ││
│  │  │                          │    │                          │     ││
│  │  │  ┌────────────────────┐  │    │  ┌────────────────────┐  │     ││
│  │  │  │ Pod 2              │  │    │  │ Pod 2              │  │     ││
│  │  │  │ frontend:latest    │  │    │  │ backend:latest     │  │     ││
│  │  │  │ Port: 80           │  │    │  │ Port: 3000         │  │     ││
│  │  │  └────────────────────┘  │    │  └────────────────────┘  │     ││
│  │  └──────────────────────────┘    └──────────────────────────┘     ││
│  │              │                                 │                   ││
│  │              ▼                                 ▼                   ││
│  │  ┌──────────────────────────┐    ┌──────────────────────────┐     ││
│  │  │  Service: frontend       │    │  Service: backend        │     ││
│  │  │  Type: NodePort          │    │  Type: NodePort          │     ││
│  │  │  Port: 80                │    │  Port: 3000              │     ││
│  │  │  NodePort: 30002         │    │  NodePort: 30001         │     ││
│  │  └──────────────────────────┘    └──────────────────────────┘     ││
│  │              │                                 │                   ││
│  └──────────────┼─────────────────────────────────┼───────────────────┘│
│                 │                                 │                    │
│                 │                                 │                    │
└─────────────────┼─────────────────────────────────┼────────────────────┘
                  │                                 │
                  ▼                                 ▼
          localhost:30002                   localhost:30001
          (Frontend Web)                    (Backend API)
```

## Cluster PROD - Detalhamento

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        k3d-desafio-prod                                   │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐│
│  │                    Kubernetes Namespace: default                    ││
│  │                                                                     ││
│  │  ┌──────────────────────────┐    ┌──────────────────────────┐     ││
│  │  │  Frontend Deployment     │    │  Backend Deployment      │     ││
│  │  │  Replicas: 3             │    │  Replicas: 3             │     ││
│  │  │                          │    │                          │     ││
│  │  │  ┌────────────────────┐  │    │  ┌────────────────────┐  │     ││
│  │  │  │ Pod 1              │  │    │  │ Pod 1              │  │     ││
│  │  │  │ frontend:latest    │  │    │  │ backend:latest     │  │     ││
│  │  │  │ Resources:         │  │    │  │ Resources:         │  │     ││
│  │  │  │ - CPU: 100-200m    │  │    │  │ - CPU: 200-500m    │  │     ││
│  │  │  │ - Mem: 64-128Mi    │  │    │  │ - Mem: 128-256Mi   │  │     ││
│  │  │  └────────────────────┘  │    │  └────────────────────┘  │     ││
│  │  │                          │    │                          │     ││
│  │  │  ┌────────────────────┐  │    │  ┌────────────────────┐  │     ││
│  │  │  │ Pod 2              │  │    │  │ Pod 2              │  │     ││
│  │  │  └────────────────────┘  │    │  └────────────────────┘  │     ││
│  │  │                          │    │                          │     ││
│  │  │  ┌────────────────────┐  │    │  ┌────────────────────┐  │     ││
│  │  │  │ Pod 3              │  │    │  │ Pod 3              │  │     ││
│  │  │  └────────────────────┘  │    │  └────────────────────┘  │     ││
│  │  └──────────────────────────┘    └──────────────────────────┘     ││
│  │              │                                 │                   ││
│  │              ▼                                 ▼                   ││
│  │  ┌──────────────────────────┐    ┌──────────────────────────┐     ││
│  │  │  Service: frontend       │    │  Service: backend        │     ││
│  │  │  Type: NodePort          │    │  Type: NodePort          │     ││
│  │  │  Port: 80                │    │  Port: 3000              │     ││
│  │  │  NodePort: 30102         │    │  NodePort: 30101         │     ││
│  │  └──────────────────────────┘    └──────────────────────────┘     ││
│  │              │                                 │                   ││
│  └──────────────┼─────────────────────────────────┼───────────────────┘│
│                 │                                 │                    │
│                 │                                 │                    │
└─────────────────┼─────────────────────────────────┼────────────────────┘
                  │                                 │
                  ▼                                 ▼
          localhost:30102                   localhost:30101
          (Frontend Web)                    (Backend API)
```

## Fluxo de Comunicação

```
┌──────────────┐
│   Browser    │
│   (User)     │
└──────┬───────┘
       │
       │ HTTP GET http://localhost:30002
       │
       ▼
┌─────────────────────────────────┐
│   Frontend (Nginx)              │
│   - Serve HTML/CSS/JS           │
│   - Executa no browser          │
└─────────┬───────────────────────┘
          │
          │ JavaScript fetch()
          │ HTTP GET http://localhost:30001/dados
          │
          ▼
┌─────────────────────────────────┐
│   Backend (Node.js/Express)     │
│   - Processa requisição         │
│   - Retorna JSON estático       │
│   - CORS habilitado             │
└─────────┬───────────────────────┘
          │
          │ JSON Response
          │
          ▼
┌─────────────────────────────────┐
│   Frontend JavaScript           │
│   - Renderiza dados na tela     │
│   - Atualiza DOM                │
└─────────────────────────────────┘
```

## Componentes da Stack

### Backend (Node.js + Express)
```
backend/
├── Dockerfile
│   └── Base: node:18-alpine
│       └── Expõe porta 3000
├── package.json
│   └── Dependencies: express, cors
└── index.js
    ├── GET /         → Info da API
    ├── GET /health   → Health check
    └── GET /dados    → Dados dummy
```

### Frontend (HTML + Nginx)
```
frontend/
├── Dockerfile
│   └── Base: nginx:alpine
│       └── Expõe porta 80
├── nginx.conf
│   └── Configuração do servidor
└── index.html
    ├── HTML5 + CSS3
    ├── Vanilla JavaScript
    └── Fetch API para consumir backend
```

### Infraestrutura (Terraform)
```
terraform/
├── main.tf
│   ├── Provider k3d
│   ├── Cluster DEV
│   └── Cluster PROD
├── variables.tf
│   └── Variáveis configuráveis
└── outputs.tf
    └── URLs de acesso
```

### Kubernetes Manifests
```
k8s/
├── dev/
│   ├── backend-deployment.yaml   → 2 réplicas
│   ├── backend-service.yaml      → NodePort 30001
│   ├── frontend-deployment.yaml  → 2 réplicas
│   └── frontend-service.yaml     → NodePort 30002
└── prod/
    ├── backend-deployment.yaml   → 3 réplicas
    ├── backend-service.yaml      → NodePort 30101
    ├── frontend-deployment.yaml  → 3 réplicas
    └── frontend-service.yaml     → NodePort 30102
```

## Health Checks e Probes

### Liveness Probe
- Verifica se o container está vivo
- Reinicia o pod se falhar
- Endpoint: `/health` (backend) ou `/health` (frontend)

### Readiness Probe
- Verifica se o container está pronto para receber tráfego
- Remove do load balancer se falhar
- Endpoint: `/health` (backend) ou `/health` (frontend)

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Pipeline de Deploy

```
┌─────────────────┐
│  1. Build       │
│  Docker Images  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  2. Import      │
│  to k3d         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  3. Apply       │
│  K8s Manifests  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  4. Wait Pods   │
│  Ready          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  5. Service     │
│  Available      │
└─────────────────┘
```

## Portas Mapeadas

| Ambiente | Serviço  | Container Port | NodePort | Host Access           |
|----------|----------|----------------|----------|-----------------------|
| DEV      | Backend  | 3000           | 30001    | localhost:30001       |
| DEV      | Frontend | 80             | 30002    | localhost:30002       |
| PROD     | Backend  | 3000           | 30101    | localhost:30101       |
| PROD     | Frontend | 80             | 30102    | localhost:30102       |

## Recursos Alocados

### DEV
```
Backend:
  Requests: 100m CPU, 64Mi RAM
  Limits:   200m CPU, 128Mi RAM

Frontend:
  Requests: 50m CPU, 32Mi RAM
  Limits:   100m CPU, 64Mi RAM
```

### PROD
```
Backend:
  Requests: 200m CPU, 128Mi RAM
  Limits:   500m CPU, 256Mi RAM

Frontend:
  Requests: 100m CPU, 64Mi RAM
  Limits:   200m CPU, 128Mi RAM
```

## Estratégia de Deployment

- **Rolling Update**: Atualização gradual dos pods
- **Max Surge**: 1 pod extra durante update
- **Max Unavailable**: 0 pods indisponíveis
- **Rollback**: Automático em caso de falha

## Considerações de Segurança

1. **Imagens Alpine**: Menor superfície de ataque
2. **Non-root User**: Containers não rodam como root
3. **Resource Limits**: Previne DoS por consumo de recursos
4. **Health Checks**: Detecção rápida de falhas
5. **Network Policies**: (Pode ser implementado)
6. **CORS**: Configurado no backend
