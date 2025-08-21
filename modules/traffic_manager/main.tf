/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Traffic Manager 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/

resource "azurerm_traffic_manager_profile" "profiles" {
  for_each = var.traffic_manager_profiles

  name                = each.key
  resource_group_name = each.value.resource_group_name
  profile_status      = each.value.profile_status
  traffic_routing_method = each.value.traffic_routing_method

  dns_config {
    relative_name = each.value.dns_config.relative_name
    ttl           = each.value.dns_config.ttl
  }

  monitor_config {
    protocol                     = each.value.monitor_config.protocol
    port                         = each.value.monitor_config.port
    path                         = each.value.monitor_config.path
    interval_in_seconds          = each.value.monitor_config.interval_in_seconds
    timeout_in_seconds           = each.value.monitor_config.timeout_in_seconds
    tolerated_number_of_failures = each.value.monitor_config.tolerated_number_of_failures
  }
  tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_traffic_manager_external_endpoint" "endpoints" {
  for_each = tomap(flatten([
    for profile_key, profile in var.traffic_manager_profiles : [
      for endpoint_key, endpoint in profile.endpoints : {
        profile_key      = profile_key
        endpoint_key     = endpoint_key
        name             = endpoint_key
        target           = endpoint.target
        endpoint_location = endpoint.endpoint_location
        priority         = endpoint.priority
        weight           = endpoint.weight
      }
    ]
  ]))

  name                = each.value.name
  profile_id          = azurerm_traffic_manager_profile.profiles[each.value.profile_key].id
  target              = each.value.target
  endpoint_location   = each.value.endpoint_location
  priority            = each.value.priority
  weight              = each.value.weight
}
