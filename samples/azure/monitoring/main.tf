data "azurerm_subscription" "tfpk" {
}

data "azurerm_client_config" "tfpk" {
}

resource "azurerm_resource_group" "tfpk" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_monitor_workspace" "tfpk" {
  name                = "${var.prefix}-mw"
  resource_group_name = azurerm_resource_group.tfpk.name
  location            = azurerm_resource_group.tfpk.location
  tags = {
    key = "tfpk"
  }
}

resource "azurerm_dashboard_grafana" "tfpk" {
  name                  = "${var.prefix}-dg"
  resource_group_name   = azurerm_resource_group.tfpk.name
  location              = azurerm_resource_group.tfpk.location
  grafana_major_version = 10

  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.tfpk.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    key = "tfpk"
  }
}

resource "azurerm_role_assignment" "tfpk-gv" {
  scope                = data.azurerm_subscription.tfpk.id
  role_definition_name = "Grafana Viewer"
  principal_id         = data.azurerm_client_config.tfpk.object_id
}

resource "azurerm_role_assignment" "tfpk-mr" {
  scope                = data.azurerm_subscription.tfpk.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.tfpk.identity[0].principal_id
}
