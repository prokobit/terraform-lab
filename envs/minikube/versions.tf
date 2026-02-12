terraform {
  required_version = "~> 1.14.0"
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}