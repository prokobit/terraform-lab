data "kubectl_kustomize_documents" "gateway_api_crds" {
  target = "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.4.2"
}

data "kubectl_kustomize_documents" "vote_app" {
  target = "../../examples/kustomize/vote-app"
}

resource "minikube_cluster" "cluster" {
  cluster_name = "${var.prefix}-minikube"
  driver       = "docker"
  addons       = ["default-storageclass", "storage-provisioner"]
  base_image   = "docker.io/kicbase/stable:v0.0.48@sha256:7171c97a51623558720f8e5878e4f4637da093e2f2ed589997bedc6c1549b2b1"
}

resource "kubectl_manifest" "gateway_api_crds" {
  count             = length(data.kubectl_kustomize_documents.gateway_api_crds.documents)
  yaml_body         = element(data.kubectl_kustomize_documents.gateway_api_crds.documents, count.index)
  server_side_apply = true
  apply_only        = true
  depends_on        = [minikube_cluster.cluster]
}

resource "helm_release" "nginx_gateway_fabric" {
  repository       = "oci://ghcr.io/nginx/charts"
  chart            = "nginx-gateway-fabric"
  name             = "ngf"
  namespace        = "nginx-gateway"
  create_namespace = true
  depends_on       = [kubectl_manifest.gateway_api_crds]
}

resource "kubectl_manifest" "vote_app" {
  count      = length(data.kubectl_kustomize_documents.vote_app.documents)
  yaml_body  = element(data.kubectl_kustomize_documents.vote_app.documents, count.index)
  depends_on = [helm_release.nginx_gateway_fabric]
}
