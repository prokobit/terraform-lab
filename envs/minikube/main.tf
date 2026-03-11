data "kubectl_kustomize_documents" "gateway_api_crds" {
  target = "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.4.2"
}

resource "minikube_cluster" "cluster" {
  driver       = "docker"
  cluster_name = "${var.prefix}-minikube"
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

module "vote_app" {
  source     = "../../examples/kustomize/vote-app"
  depends_on = [helm_release.nginx_gateway_fabric]
}
