provider "azurerm" {
  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_kubernetes_cluster" "default" {
  depends_on          = [module.kubernetes] # refresh cluster state before reading
  name                = "${var.prefix}-aks"
  resource_group_name = "${var.prefix}-resources"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
  }
}