output "cluster_egress_ip" {
  value = data.azurerm_public_ip.tfpk.ip_address
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config_raw
  sensitive = true
}

output "cluster_endpoint" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config[0].host
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config[0].username
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config[0].password
  sensitive = true
}

output "cluster_client_key" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config[0].client_key
  sensitive = true
}

output "cluster_client_certificate" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config[0].client_certificate
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.tfpk.kube_config[0].cluster_ca_certificate
  sensitive = true
}

