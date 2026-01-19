#!/bin/bash

set -e

echo "========================================="
echo "Cleaning up resources"
echo "========================================="

echo ""
echo "Destroying Terraform resources..."
cd terraform
terraform destroy -auto-approve
cd ..

echo ""
echo "========================================="
echo "Cleanup completed!"
echo "========================================="
