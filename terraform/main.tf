terraform {
  required_providers {
    k3d = {
      source  = "pvotal-tech/k3d"
      version = "~> 0.0.7"
    }
  }
}

provider "k3d" {}

# Cluster de desenvolvimento
resource "k3d_cluster" "dev" {
  name    = "desafio-dev"
  servers = 1
  agents  = 1

  port {
    host_port      = 30001
    container_port = 30001
    node_filters = [
      "server:0",
    ]
  }

  port {
    host_port      = 30002
    container_port = 30002
    node_filters = [
      "server:0",
    ]
  }

  k3d {
    disable_load_balancer = false
  }

  k3s {
    extra_args {
      arg          = "--disable=traefik"
      node_filters = [
        "server:*",
      ]
    }
  }

  image   = "rancher/k3s:v1.27.4-k3s1"
  network = "desafio-network-dev"

  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = true
  }
}

# Cluster de produção
resource "k3d_cluster" "prod" {
  name    = "desafio-prod"
  servers = 1
  agents  = 2

  port {
    host_port      = 30101
    container_port = 30101
    node_filters = [
      "server:0",
    ]
  }

  port {
    host_port      = 30102
    container_port = 30102
    node_filters = [
      "server:0",
    ]
  }

  k3d {
    disable_load_balancer = false
  }

  k3s {
    extra_args {
      arg          = "--disable=traefik"
      node_filters = [
        "server:*",
      ]
    }
  }

  image   = "rancher/k3s:v1.27.4-k3s1"
  network = "desafio-network-prod"

  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = false
  }
}
