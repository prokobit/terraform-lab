resource "minikube_cluster" "cluster" {
  cluster_name = "${var.prefix}-ingress"
  driver       = "docker"
  addons       = ["default-storageclass", "storage-provisioner"]
  base_image   = "docker.io/kicbase/stable:v0.0.48@sha256:7171c97a51623558720f8e5878e4f4637da093e2f2ed589997bedc6c1549b2b1"
}

## NGINX INGRESS CONTROLLER

resource "helm_release" "nginx_ingress" {
  name             = "nic"
  repository       = "oci://ghcr.io/nginx/charts"
  chart            = "nginx-ingress"
  namespace        = "default"
  depends_on       = [minikube_cluster.cluster]
}

data "kubectl_kustomize_documents" "ingress_vote_app" {
  target = "../../examples/kustomize/ingress-vote-app"
}

resource "kubectl_manifest" "ingress_vote_app" {
  count      = length(data.kubectl_kustomize_documents.ingress_vote_app.documents)
  yaml_body  = element(data.kubectl_kustomize_documents.ingress_vote_app.documents, count.index)
  depends_on = [helm_release.nginx_ingress]
}
