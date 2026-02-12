output "public_ip_address" {
  value = azurerm_container_group.tfpk.ip_address
}

output "public_fqdn" {
  value = azurerm_container_group.tfpk.fqdn
}