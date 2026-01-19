# Guia de Testes

Este documento descreve como testar a solução completa após o deploy.

## Testes de Infraestrutura

### 1. Verificar Clusters k3d

```bash
# Listar clusters criados
k3d cluster list

# Saída esperada:
# NAME            SERVERS   AGENTS   LOADBALANCER
# desafio-dev     1/1       1/1      true
# desafio-prod    1/1       2/2      true
```

### 2. Verificar Contextos Kubernetes

```bash
# Listar contextos
kubectl config get-contexts

# Saída esperada deve incluir:
# k3d-desafio-dev
# k3d-desafio-prod
```

### 3. Verificar Nodes

```bash
# DEV
kubectl get nodes --context k3d-desafio-dev

# PROD
kubectl get nodes --context k3d-desafio-prod
```

## Testes de Deploy

### 1. Verificar Pods (DEV)

```bash
kubectl get pods --context k3d-desafio-dev

# Saída esperada:
# NAME                        READY   STATUS    RESTARTS   AGE
# backend-xxxxxxxxxx-xxxxx    1/1     Running   0          Xm
# backend-xxxxxxxxxx-xxxxx    1/1     Running   0          Xm
# frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
# frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
```

### 2. Verificar Pods (PROD)

```bash
kubectl get pods --context k3d-desafio-prod

# Saída esperada:
# NAME                        READY   STATUS    RESTARTS   AGE
# backend-xxxxxxxxxx-xxxxx    1/1     Running   0          Xm
# backend-xxxxxxxxxx-xxxxx    1/1     Running   0          Xm
# backend-xxxxxxxxxx-xxxxx    1/1     Running   0          Xm
# frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
# frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
# frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
```

### 3. Verificar Services

```bash
# DEV
kubectl get services --context k3d-desafio-dev

# PROD
kubectl get services --context k3d-desafio-prod
```

## Testes de Aplicação

### 1. Backend DEV - Health Check

```bash
curl http://localhost:30001/health

# Saída esperada:
# {
#   "status": "OK",
#   "environment": "dev",
#   "timestamp": "2025-01-18T..."
# }
```

### 2. Backend DEV - Root Endpoint

```bash
curl http://localhost:30001/

# Saída esperada:
# {
#   "service": "Backend Dummy API",
#   "version": "1.0.0",
#   "environment": "dev",
#   "endpoints": [...]
# }
```

### 3. Backend DEV - Dados

```bash
curl http://localhost:30001/dados

# Saída esperada: JSON com usuários e produtos
```

### 4. Backend PROD - Endpoints

```bash
# Health
curl http://localhost:30101/health

# Root
curl http://localhost:30101/

# Dados
curl http://localhost:30101/dados
```

### 5. Frontend DEV

```bash
# Health check
curl http://localhost:30002/health

# Abrir no browser
open http://localhost:30002
# ou
xdg-open http://localhost:30002
```

### 6. Frontend PROD

```bash
# Health check
curl http://localhost:30102/health

# Abrir no browser
open http://localhost:30102
# ou
xdg-open http://localhost:30102
```

## Testes de Resiliência

### 1. Escalar Pods

```bash
# Escalar backend DEV para 5 réplicas
kubectl scale deployment backend --replicas=5 --context k3d-desafio-dev

# Verificar
kubectl get pods --context k3d-desafio-dev

# Voltar ao normal
kubectl scale deployment backend --replicas=2 --context k3d-desafio-dev
```

### 2. Deletar um Pod

```bash
# Listar pods
kubectl get pods --context k3d-desafio-dev

# Deletar um pod específico
kubectl delete pod <pod-name> --context k3d-desafio-dev

# Verificar que Kubernetes recria automaticamente
kubectl get pods --context k3d-desafio-dev -w
```

### 3. Simular Falha

```bash
# Executar comando que falha dentro do pod
kubectl exec -it <backend-pod-name> --context k3d-desafio-dev -- sh -c "exit 1"

# Verificar que o pod é reiniciado
kubectl get pods --context k3d-desafio-dev
```

## Testes de Logs

### 1. Ver Logs do Backend

```bash
# DEV
kubectl logs -l app=backend --context k3d-desafio-dev

# PROD
kubectl logs -l app=backend --context k3d-desafio-prod

# Seguir logs em tempo real
kubectl logs -f -l app=backend --context k3d-desafio-dev
```

### 2. Ver Logs do Frontend

```bash
# DEV
kubectl logs -l app=frontend --context k3d-desafio-dev

# PROD
kubectl logs -l app=frontend --context k3d-desafio-prod
```

## Testes de Performance

### 1. Teste de Carga Simples (usando ab - Apache Bench)

```bash
# Instalar ab (se necessário)
# Ubuntu/Debian: sudo apt-get install apache2-utils
# macOS: brew install httpd

# Teste com 1000 requisições, 10 concorrentes
ab -n 1000 -c 10 http://localhost:30001/dados

# Verificar se todos os pods estão distribuindo carga
kubectl top pods --context k3d-desafio-dev
```

### 2. Teste de Carga com curl

```bash
# Script simples de teste
for i in {1..100}; do
  curl -s http://localhost:30001/dados > /dev/null
  echo "Request $i completed"
done
```

## Testes de Variáveis de Ambiente

### 1. Verificar Variável ENVIRONMENT

```bash
# DEV - deve retornar "dev"
curl http://localhost:30001/health | jq .environment

# PROD - deve retornar "prod"
curl http://localhost:30101/health | jq .environment
```

### 2. Verificar dentro do Pod

```bash
# Entrar no pod
kubectl exec -it <backend-pod-name> --context k3d-desafio-dev -- sh

# Dentro do pod
echo $ENVIRONMENT
env | grep ENVIRONMENT
exit
```

## Testes de Rede

### 1. DNS Interno

```bash
# Entrar em um pod frontend
kubectl exec -it <frontend-pod-name> --context k3d-desafio-dev -- sh

# Dentro do pod, testar resolução DNS
nslookup backend
ping backend

# Testar conectividade
wget -O- http://backend:3000/health
```

### 2. Conectividade entre Pods

```bash
# Do frontend, acessar backend
kubectl exec -it <frontend-pod-name> --context k3d-desafio-dev -- \
  wget -qO- http://backend:3000/dados
```

## Testes de Recursos

### 1. Verificar Uso de CPU e Memória

```bash
# DEV
kubectl top pods --context k3d-desafio-dev

# PROD
kubectl top pods --context k3d-desafio-prod

# Ver nodes
kubectl top nodes --context k3d-desafio-dev
```

### 2. Verificar Limits e Requests

```bash
kubectl describe pod <pod-name> --context k3d-desafio-dev | grep -A 5 "Limits\|Requests"
```

## Testes de Atualização

### 1. Update de Imagem

```bash
# Fazer alteração no código do backend
# Rebuild da imagem
./scripts/build-images.sh

# Reimportar
k3d image import backend-dummy:latest -c desafio-dev

# Forçar restart dos pods
kubectl rollout restart deployment backend --context k3d-desafio-dev

# Acompanhar rollout
kubectl rollout status deployment backend --context k3d-desafio-dev
```

## Checklist de Validação

Use este checklist para validar se tudo está funcionando:

### Infraestrutura
- [ ] Clusters k3d criados (dev e prod)
- [ ] Nodes ativos
- [ ] Contextos kubectl configurados

### Deploy DEV
- [ ] 2 pods backend rodando
- [ ] 2 pods frontend rodando
- [ ] Services criados
- [ ] NodePorts acessíveis (30001, 30002)

### Deploy PROD
- [ ] 3 pods backend rodando
- [ ] 3 pods frontend rodando
- [ ] Services criados
- [ ] NodePorts acessíveis (30101, 30102)

### Aplicação DEV
- [ ] Backend health check OK
- [ ] Backend retorna dados
- [ ] Frontend carrega no browser
- [ ] Frontend consome API com sucesso
- [ ] Variável ENVIRONMENT = "dev"

### Aplicação PROD
- [ ] Backend health check OK
- [ ] Backend retorna dados
- [ ] Frontend carrega no browser
- [ ] Frontend consome API com sucesso
- [ ] Variável ENVIRONMENT = "prod"

### Resiliência
- [ ] Pods são recriados automaticamente quando deletados
- [ ] Health checks funcionam
- [ ] Load balancing entre pods funciona

## Comandos de Debug

### Ver eventos do cluster
```bash
kubectl get events --sort-by='.lastTimestamp' --context k3d-desafio-dev
```

### Descrever recurso
```bash
kubectl describe deployment backend --context k3d-desafio-dev
kubectl describe service backend --context k3d-desafio-dev
kubectl describe pod <pod-name> --context k3d-desafio-dev
```

### Ver configuração
```bash
kubectl get deployment backend -o yaml --context k3d-desafio-dev
kubectl get service backend -o yaml --context k3d-desafio-dev
```

### Port-forward (debug alternativo)
```bash
kubectl port-forward svc/backend 8080:3000 --context k3d-desafio-dev
# Acessar: http://localhost:8080
```

## Resultados Esperados

### Frontend no Browser

Ao abrir http://localhost:30002 ou http://localhost:30102, você deve ver:

1. **Header** com título "Frontend Dummy - Desafio DevOps"
2. **Badge** mostrando o ambiente (DEV em amarelo ou PROD em verde)
3. **Botões** "Carregar Dados" e "Verificar Health"
4. **URL do backend** exibida
5. **Tabelas** com dados de usuários e produtos quando clicar em "Carregar Dados"

### API no Terminal

```bash
$ curl http://localhost:30001/dados
{
  "message": "Dados do backend dummy",
  "environment": "dev",
  "data": {
    "usuarios": [...],
    "produtos": [...]
  },
  "timestamp": "..."
}
```

## Troubleshooting

Se algum teste falhar, consulte o README.md seção de Troubleshooting ou:

1. Verificar logs: `kubectl logs <pod-name>`
2. Verificar eventos: `kubectl get events`
3. Descrever pod: `kubectl describe pod <pod-name>`
4. Verificar se imagens foram importadas: `k3d image list -c desafio-dev`
