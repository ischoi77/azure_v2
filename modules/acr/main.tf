resource "azurerm_container_registry" "acr" {
  for_each = var.acr_config

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = var.location
  sku                 = each.value.sku
  admin_enabled       = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled

  tags = merge(var.common_tags, each.value.tags)
 
  retention_policy_in_days   = each.value.retention_policy_enabled ? each.value.retention_policy_days : null
  quarantine_policy_enabled = each.value.quarantine_policy_enabled
  trust_policy_enabled      = each.value.trust_policy_enabled

  # 만약 user_assigned_identity_ids 맵에 현재 리소스 이름(each.key)과 일치하는 값이 있다면 identity 블록 추가
  dynamic "identity" {
    for_each = contains(keys(var.user_assigned_identity_ids), each.value.identity.identity_ids) ? [var.user_assigned_identity_ids[each.value.identity.identity_ids]] : []
    content {
      type = each.value.identity.type
      identity_ids = (
      // identity_type 문자열을 쉼표로 분리한 배열에 "UserAssigned"가 포함되어 있고,
      // 동일한 이름의 Identity가 조회되었으면 그 ID를 적용하고, 없으면 빈 리스트
      contains(split(",", each.value.identity.type), "UserAssigned") && contains(keys(var.user_assigned_identity_ids), each.value.identity.identity_ids)
        ? [var.user_assigned_identity_ids[each.value.identity.identity_ids]]
        : []
      )
    }
  }
  
  dynamic "network_rule_set" {
    for_each = each.value.network_rule_set != null ? [each.value.network_rule_set] : []
    content {
      default_action           = network_rule_set.value.default_action
      ip_rule                  = length(network_rule_set.value.ip_rules) > 0 ? [for ip in network_rule_set.value.ip_rules : { action = "Allow", ip_range = ip }] : []
    }
  }


  lifecycle {
    ignore_changes = [ identity, identity[0].identity_ids ]
  }
}


## 이하 private endpoint 값이 True 일때만 생성 

resource "azurerm_private_endpoint" "acr_pe" {
  for_each = {
    for k, v in var.acr_config : k => v
    if v.private_endpoint_enabled == true
  }

  name                = "acr-${each.key}-pe"
  resource_group_name = each.value.resource_group_name
  location           = var.location
  subnet_id          = var.subnet_ids[each.value.subnet_name]

  private_service_connection {
    name                           = "${each.key}-connection"
    private_connection_resource_id = azurerm_container_registry.acr[each.key].id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "privatelink.azurecr.io"
    private_dns_zone_ids = [each.value.private_dns_zone_id]
  }
  custom_network_interface_name = each.value.custom_network_interface_name

 tags = merge(var.common_tags, each.value.acr_pe_tags)
}

data "azurerm_virtual_network" "vnet_name" {
    for_each = {
    for k, v in var.acr_config : k => v
    if v.private_endpoint_enabled == true
  } 
  name                = each.value.vnet_name
  resource_group_name = each.value.vnet_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  for_each = {
    for k, v in var.acr_config : k => v
    if v.private_endpoint_enabled == true
  }  
  name                  = "${each.value.resource_group_name}-to-${each.value.vnet_name}-link"
  resource_group_name   = each.value.vnet_resource_group_name
  private_dns_zone_name = "privatelink.azurecr.io"
  virtual_network_id    = data.azurerm_virtual_network.vnet_name[each.key].id
}