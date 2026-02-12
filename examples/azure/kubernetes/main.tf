resource "azurerm_resource_group" "tfpk" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "tfpk" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.tfpk.location
  resource_group_name = azurerm_resource_group.tfpk.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tfpk" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.tfpk.name
  virtual_network_name = azurerm_virtual_network.tfpk.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "tfpk" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.tfpk.location
  resource_group_name = azurerm_resource_group.tfpk.name
  dns_prefix          = "${var.prefix}-aks"

  default_node_pool {
    name       = "${var.prefix}pool"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  // monitor_metrics {}

  identity {
    type = "SystemAssigned"
  }

  tags = {
    key = "tfpk"
  }
}

data "azurerm_public_ip" "tfpk" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.tfpk.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.tfpk.node_resource_group
}