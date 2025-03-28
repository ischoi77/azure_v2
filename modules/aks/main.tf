
resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = var.kubernetes_clusters
  name                = each.key
  location            = var.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix

  kubernetes_version  = each.value.kubernetes_version

  default_node_pool {
    name            = "default"
    vm_size         = each.value.node_pool.vm_size
    node_count      = each.value.node_pool.node_count
    os_disk_size_gb = each.value.node_pool.os_disk_size
    max_pods        = each.value.node_pool.max_pods
    type            = each.value.node_pool.type
  }

  identity {
    type = each.value.identity.type
  }

  dynamic "network_profile" {
    for_each = each.value.network_profile == null ? [] : [each.value.network_profile]
    content {
      network_plugin     = network_profile.value.network_plugin
      network_plugin_mode = network_profile.value.network_plugin_mode
      network_data_plane = network_profile.value.network_data_plane
      network_mode       = network_profile.value.network_mode
      network_policy     = network_profile.value.network_policy
      dns_service_ip     = network_profile.value.dns_service_ip
      service_cidr       = network_profile.value.service_cidr
      service_cidrs = network_profile.value.service_cidrs
      outbound_type = network_profile.value.outbound_type
      pod_cidr = network_profile.value.pod_cidr
      pod_cidrs = network_profile.value.pod_cidrs
      ip_versions = network_profile.value.ip_versions
      load_balancer_sku = network_profile.value.load_balancer_sku
      load_balancer_profile {

        
      }
      nat_gateway_profile {
        
      }

      #docker_bridge_cidr = network_profile.value.docker_bridge_cidr
    }
  }

  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = { for cluster_name, config in var.kubernetes_clusters : cluster_name => config.additional_node_pools if length(config.additional_node_pools) > 0 }

  name                  = each.key
  vm_size = ""
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[each.key].id

  dynamic "node_pool" {
    for_each = tomap(each.value)
    content {
      name            = node_pool.key
      vm_size         = node_pool.value.vm_size
      node_count      = node_pool.value.node_count
      os_disk_size_gb = node_pool.value.os_disk_size
      max_pods        = node_pool.value.max_pods
      type            = node_pool.value.type
    }
  }

  tags = merge(var.common_tags, var.kubernetes_clusters[each.key].tags)
}

