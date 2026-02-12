resource "azurerm_kubernetes_cluster" "tfpk" {
  name                = "${var.prefix}-aks"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  dns_prefix          = "${var.prefix}-aks"

  default_node_pool {
    name       = "${var.prefix}pool"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  monitor_metrics {}

  identity {
    type = "SystemAssigned"
  }

  tags = {
    key = var.prefix
  }
}

resource "azurerm_monitor_data_collection_rule_association" "tfpk" {
  name                    = "${var.prefix}-dcra"
  target_resource_id      = azurerm_kubernetes_cluster.tfpk.id
  data_collection_rule_id = var.data_collection_rule_id
}

data "azurerm_public_ip" "tfpk" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.tfpk.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.tfpk.node_resource_group
}