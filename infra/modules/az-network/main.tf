resource "azurerm_virtual_network" "tfpk" {
  name                = "${var.prefix}-vnet"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tfpk" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.tfpk.name
  address_prefixes     = ["10.0.1.0/24"]
}
