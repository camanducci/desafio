variable "dev_cluster_name" {
  description = "Nome do cluster de desenvolvimento"
  type        = string
  default     = "desafio-dev"
}

variable "prod_cluster_name" {
  description = "Nome do cluster de produção"
  type        = string
  default     = "desafio-prod"
}

variable "k3s_version" {
  description = "Versão do K3s"
  type        = string
  default     = "v1.27.4-k3s1"
}

variable "dev_backend_nodeport" {
  description = "NodePort do backend em dev"
  type        = number
  default     = 30001
}

variable "dev_frontend_nodeport" {
  description = "NodePort do frontend em dev"
  type        = number
  default     = 30002
}

variable "prod_backend_nodeport" {
  description = "NodePort do backend em prod"
  type        = number
  default     = 30101
}

variable "prod_frontend_nodeport" {
  description = "NodePort do frontend em prod"
  type        = number
  default     = 30102
}
