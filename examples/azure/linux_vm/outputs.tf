data "azurerm_public_ip" "tfpk" {
  name                = azurerm_public_ip.tfpk.name
  resource_group_name = azurerm_linux_virtual_machine.tfpk.resource_group_name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.tfpk.ip_address
}