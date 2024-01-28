resource "azurerm_resource_group" "tfpk" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

module "network" {
  source         = "../../modules/az-network"
  resource_group = azurerm_resource_group.tfpk
  prefix         = var.prefix
}

module "monitor" {
  source         = "../../modules/az-monitor"
  resource_group = azurerm_resource_group.tfpk
  prefix         = var.prefix
}

module "kubernetes" {
  source                  = "../../modules/az-kubernetes"
  resource_group          = azurerm_resource_group.tfpk
  prefix                  = var.prefix
  data_collection_rule_id = module.monitor.data_collection_rule_id
}
