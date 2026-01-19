output "dev_cluster_name" {
  description = "Nome do cluster de desenvolvimento"
  value       = k3d_cluster.dev.name
}

output "prod_cluster_name" {
  description = "Nome do cluster de produção"
  value       = k3d_cluster.prod.name
}

output "dev_access_info" {
  description = "Informações de acesso ao ambiente dev"
  value = {
    backend_url  = "http://localhost:30001"
    frontend_url = "http://localhost:30002"
    kubectl_context = "k3d-desafio-dev"
  }
}

output "prod_access_info" {
  description = "Informações de acesso ao ambiente prod"
  value = {
    backend_url  = "http://localhost:30101"
    frontend_url = "http://localhost:30102"
    kubectl_context = "k3d-desafio-prod"
  }
}
