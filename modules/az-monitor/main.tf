resource "azurerm_monitor_workspace" "tfpk" {
  name                = "${var.prefix}-mw"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags = {
    key = var.prefix
  }
}

resource "azurerm_monitor_data_collection_endpoint" "tfpk" {
  name                = "${var.prefix}-mdce"
  location            = azurerm_monitor_workspace.tfpk.location
  resource_group_name = azurerm_monitor_workspace.tfpk.resource_group_name
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "tfpk" {
  name                        = "${var.prefix}-mdcr"
  location                    = azurerm_monitor_data_collection_endpoint.tfpk.location
  resource_group_name         = azurerm_monitor_data_collection_endpoint.tfpk.resource_group_name
  kind                        = azurerm_monitor_data_collection_endpoint.tfpk.kind
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.tfpk.id

  data_flow {
    destinations = ["${var.prefix}-MonitoringAccount"]
    streams      = ["Microsoft-PrometheusMetrics"]
  }
  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }
  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.tfpk.id
      name               = "${var.prefix}-MonitoringAccount"
    }
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "tfpk-k8s" {
  name                = "${var.prefix}-KubernetesRecordingRulesRuleGroup"
  location            = azurerm_monitor_workspace.tfpk.location
  resource_group_name = azurerm_monitor_workspace.tfpk.resource_group_name
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [azurerm_monitor_workspace.tfpk.id]
  //cluster_name        = "tfpk-aks"
  rule {
    expression = "sum by (cluster, namespace, pod, container) (  irate(container_cpu_usage_seconds_total{job=\"cadvisor\", image!=\"\"}[5m])) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (  1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=\"\"}))"
    record     = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate"
    enabled    = true
  }
  rule {
    expression = "container_memory_working_set_bytes{job=\"cadvisor\", image!=\"\"}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=\"\"}))"
    record     = "node_namespace_pod_container:container_memory_working_set_bytes"
    enabled    = true
  }
  rule {
    expression = "container_memory_rss{job=\"cadvisor\", image!=\"\"}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=\"\"}))"
    record     = "node_namespace_pod_container:container_memory_rss"
    enabled    = true
  }
  rule {
    expression = "container_memory_cache{job=\"cadvisor\", image!=\"\"}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=\"\"}))"
    record     = "node_namespace_pod_container:container_memory_cache"
    enabled    = true
  }
  rule {
    expression = "container_memory_swap{job=\"cadvisor\", image!=\"\"}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=\"\"}))"
    record     = "node_namespace_pod_container:container_memory_swap"
    enabled    = true
  }
  rule {
    expression = "kube_pod_container_resource_requests{resource=\"memory\",job=\"kube-state-metrics\"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1))"
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests"
    enabled    = true
  }
  rule {
    expression = "sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource=\"memory\",job=\"kube-state-metrics\"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~\"Pending|Running\"} == 1        )    ))"
    record     = "namespace_memory:kube_pod_container_resource_requests:sum"
    enabled    = true
  }
  rule {
    expression = "kube_pod_container_resource_requests{resource=\"cpu\",job=\"kube-state-metrics\"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1))"
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests"
  }
  rule {
    expression = "sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource=\"cpu\",job=\"kube-state-metrics\"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~\"Pending|Running\"} == 1        )    ))"
    record     = "namespace_cpu:kube_pod_container_resource_requests:sum"
    enabled    = true
  }
  rule {
    expression = "kube_pod_container_resource_limits{resource=\"memory\",job=\"kube-state-metrics\"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1))"
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits"
    enabled    = true
  }
  rule {
    expression = "sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource=\"memory\",job=\"kube-state-metrics\"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~\"Pending|Running\"} == 1        )    ))"
    record     = "namespace_memory:kube_pod_container_resource_limits:sum"
    enabled    = true
  }
  rule {
    expression = "kube_pod_container_resource_limits{resource=\"cpu\",job=\"kube-state-metrics\"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ( (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1) )"
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits"
    enabled    = true
  }
  rule {
    expression = "sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource=\"cpu\",job=\"kube-state-metrics\"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~\"Pending|Running\"} == 1        )    ))"
    record     = "namespace_cpu:kube_pod_container_resource_limits:sum"
    enabled    = true
  }
  rule {
    expression = "max by (cluster, namespace, workload, pod) (  label_replace(    label_replace(      kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"ReplicaSet\"},      \"replicaset\", \"$1\", \"owner_name\", \"(.*)\"    ) * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (      1, max by (replicaset, namespace, owner_name) (        kube_replicaset_owner{job=\"kube-state-metrics\"}      )    ),    \"workload\", \"$1\", \"owner_name\", \"(.*)\"  ))"
    labels = {
      workload_type = "deployment"
    }
    record  = "namespace_workload_pod:kube_pod_owner:relabel"
    enabled = true
  }
  rule {
    expression = "max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"DaemonSet\"},    \"workload\", \"$1\", \"owner_name\", \"(.*)\"  ))"
    labels = {
      workload_type = "daemonset"
    }
    record  = "namespace_workload_pod:kube_pod_owner:relabel"
    enabled = true
  }
  rule {
    expression = "max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"StatefulSet\"},    \"workload\", \"$1\", \"owner_name\", \"(.*)\"  ))"
    labels = {
      workload_type = "statefulset"
    }
    record  = "namespace_workload_pod:kube_pod_owner:relabel"
    enabled = true
  }
  rule {
    expression = "max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"Job\"},    \"workload\", \"$1\", \"owner_name\", \"(.*)\"  ))"
    labels = {
      workload_type = "job"
    }
    record  = "namespace_workload_pod:kube_pod_owner:relabel"
    enabled = true
  }
  rule {
    expression = "sum(  node_memory_MemAvailable_bytes{job=\"node\"} or  (    node_memory_Buffers_bytes{job=\"node\"} +    node_memory_Cached_bytes{job=\"node\"} +    node_memory_MemFree_bytes{job=\"node\"} +    node_memory_Slab_bytes{job=\"node\"}  )) by (cluster)"
    record     = ":node_memory_MemAvailable_bytes:sum"
    enabled    = true
  }
  rule {
    expression = "sum(rate(node_cpu_seconds_total{job=\"node\",mode!=\"idle\",mode!=\"iowait\",mode!=\"steal\"}[5m])) by (cluster) /count(sum(node_cpu_seconds_total{job=\"node\"}) by (cluster, instance, cpu)) by (cluster)"
    record     = "cluster:node_cpu:ratio_rate5m"
    enabled    = true
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "tfpk-node" {
  name                = "${var.prefix}-NodeRecordingRulesRuleGroup"
  location            = azurerm_monitor_workspace.tfpk.location
  resource_group_name = azurerm_monitor_workspace.tfpk.resource_group_name
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [azurerm_monitor_workspace.tfpk.id]
  // cluster_name        = "tfpk-aks"
  rule {
    expression = "count without (cpu, mode) (  node_cpu_seconds_total{job=\"node\",mode=\"idle\"})"
    record     = "instance:node_num_cpu:sum"
    enabled    = true
  }
  rule {
    expression = "1 - avg without (cpu) (  sum without (mode) (rate(node_cpu_seconds_total{job=\"node\", mode=~\"idle|iowait|steal\"}[5m])))"
    record     = "instance:node_cpu_utilisation:rate5m"
    enabled    = true
  }
  rule {
    expression = "(  node_load1{job=\"node\"}/  instance:node_num_cpu:sum{job=\"node\"})"
    record     = "instance:node_load1_per_cpu:ratio"
    enabled    = true
  }
  rule {
    expression = "1 - (  (    node_memory_MemAvailable_bytes{job=\"node\"}    or    (      node_memory_Buffers_bytes{job=\"node\"}      +      node_memory_Cached_bytes{job=\"node\"}      +      node_memory_MemFree_bytes{job=\"node\"}      +      node_memory_Slab_bytes{job=\"node\"}    )  )/  node_memory_MemTotal_bytes{job=\"node\"})"
    record     = "instance:node_memory_utilisation:ratio"
    enabled    = true
  }
  rule {
    expression = "rate(node_vmstat_pgmajfault{job=\"node\"}[5m])"
    record     = "instance:node_vmstat_pgmajfault:rate5m"
    enabled    = true
  }
  rule {
    expression = "rate(node_disk_io_time_seconds_total{job=\"node\", device!=\"\"}[5m])"
    record     = "instance_device:node_disk_io_time_seconds:rate5m"
    enabled    = true
  }
  rule {
    expression = "rate(node_disk_io_time_weighted_seconds_total{job=\"node\", device!=\"\"}[5m])"
    record     = "instance_device:node_disk_io_time_weighted_seconds:rate5m"
    enabled    = true
  }
  rule {
    expression = "sum without (device) (  rate(node_network_receive_bytes_total{job=\"node\", device!=\"lo\"}[5m]))"
    record     = "instance:node_network_receive_bytes_excluding_lo:rate5m"
    enabled    = true
  }
  rule {
    expression = "sum without (device) (  rate(node_network_transmit_bytes_total{job=\"node\", device!=\"lo\"}[5m]))"
    record     = "instance:node_network_transmit_bytes_excluding_lo:rate5m"
    enabled    = true
  }
  rule {
    expression = "sum without (device) (  rate(node_network_receive_drop_total{job=\"node\", device!=\"lo\"}[5m]))"
    record     = "instance:node_network_receive_drop_excluding_lo:rate5m"
    enabled    = true
  }
  rule {
    expression = "sum without (device) (  rate(node_network_transmit_drop_total{job=\"node\", device!=\"lo\"}[5m]))"
    record     = "instance:node_network_transmit_drop_excluding_lo:rate5m"
    enabled    = true
  }
}

# resource "azurerm_monitor_data_collection_rule_association" "tfpk" {
#   name                    = "${var.prefix}-dcra"
#   target_resource_id      = var.kubernetes_cluster_id
#   data_collection_rule_id = var.data_collection_rule_id
# }

# resource "azurerm_role_assignment" "tfpk-mr" {
#   scope                = data.azurerm_subscription.tfpk.id
#   role_definition_name = "Monitoring Data Reader"
#   principal_id         = azurerm_dashboard_grafana.tfpk.identity[0].principal_id
# }
