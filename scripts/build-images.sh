#!/bin/bash

set -e

echo "========================================="
echo "Building Docker Images"
echo "========================================="

# Backend
echo ""
echo "Building Backend Image..."
docker build -t backend-dummy:latest ./backend

# Frontend
echo ""
echo "Building Frontend Image..."
docker build -t frontend-dummy:latest ./frontend

echo ""
echo "========================================="
echo "Images built successfully!"
echo "========================================="
docker images | grep -E "backend-dummy|frontend-dummy"
