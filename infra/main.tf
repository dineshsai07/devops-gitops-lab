terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}

provider "kubernetes" {
  # Uses your local Docker-Desktop cluster via kubeconfig
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    # Point Helm at the same kubeconfig
    config_path = "~/.kube/config"
  }
}

# Create a dedicated namespace for the app
resource "kubernetes_namespace" "notes" {
  metadata {
    name = "notes"
  }
}

# Deploy your Helm chart into that namespace
resource "helm_release" "notes" {
  name       = "notes-api"
  namespace  = kubernetes_namespace.notes.metadata[0].name
  chart      = "../helm-chart/notes-api"
  values     = [ file("../helm-chart/notes-api/values-dev.yaml") ]

  # Optional settings to wait for rollout
  wait       = true
  timeout    = 300
}
