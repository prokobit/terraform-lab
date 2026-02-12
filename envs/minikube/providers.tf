provider "minikube" {
  kubernetes_version = "v1.30.2"
}

resource "minikube_cluster" "cluster" {
  driver       = "docker"
  cluster_name = "${var.prefix}-minikube"
}

provider "kubernetes" {
  host                   = minikube_cluster.docker.host
  client_certificate     = minikube_cluster.docker.client_certificate
  client_key             = minikube_cluster.docker.client_key
  cluster_ca_certificate = minikube_cluster.docker.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = minikube_cluster.cluster.host
    client_certificate     = minikube_cluster.cluster.client_certificate
    client_key             = minikube_cluster.cluster.client_key
    cluster_ca_certificate = minikube_cluster.cluster.cluster_ca_certificate
  }
}