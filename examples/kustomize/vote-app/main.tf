data "kubectl_kustomize_documents" "vote_app" {
  target = "${path.module}/app"
}

resource "kubectl_manifest" "vote_app" {
  #count              = length(data.kubectl_kustomize_documents.vote_app.documents)
  yaml_body = data.kubectl_kustomize_documents.vote_app.documents[0]
}