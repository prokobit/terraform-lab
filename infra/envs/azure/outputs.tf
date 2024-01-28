output "grafana_endpoint" {
  value = module.monitor.grafana_endpoint
}

output "kube_config" {
  value     = module.kubernetes.kube_config
  sensitive = true
}