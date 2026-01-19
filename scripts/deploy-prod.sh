#!/bin/bash

set -e

CLUSTER_NAME="desafio-prod"

echo "========================================="
echo "Deploying to PROD environment"
echo "========================================="

# Verificar se o cluster existe
if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Error: Cluster $CLUSTER_NAME not found!"
    echo "Please run 'terraform apply' first to create the cluster."
    exit 1
fi

# Configurar kubectl context
echo ""
echo "Switching to $CLUSTER_NAME context..."
kubectl config use-context k3d-$CLUSTER_NAME

# Importar imagens para o cluster
echo ""
echo "Importing images to k3d cluster..."
k3d image import backend-dummy:latest -c $CLUSTER_NAME
k3d image import frontend-dummy:latest -c $CLUSTER_NAME

# Aplicar manifests
echo ""
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/prod/

# Aguardar deployments
echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/backend
kubectl wait --for=condition=available --timeout=120s deployment/frontend

# Mostrar status
echo ""
echo "========================================="
echo "Deployment Status"
echo "========================================="
kubectl get pods
echo ""
kubectl get services

echo ""
echo "========================================="
echo "PROD Environment Ready!"
echo "========================================="
echo "Backend:  http://localhost:30101"
echo "Frontend: http://localhost:30102"
echo "========================================="
