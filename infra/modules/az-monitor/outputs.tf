output "grafana_endpoint" {
  value = azurerm_dashboard_grafana.tfpk.endpoint
}

output "data_collection_rule_id" {
  value = azurerm_monitor_data_collection_rule.tfpk.id
}
