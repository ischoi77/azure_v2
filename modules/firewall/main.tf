/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Firewall 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/



resource "azurerm_firewall" "firewall" {
    for_each            = var.firewall_config
    name                = each.value.firewall_name
    location            = var.location
    resource_group_name = each.value.resource_group_name
    sku_name            = each.value.sku_name
    sku_tier            = each.value.sku_tier1

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = var.subnet_ids[each.value.subnet_name]
    public_ip_address_id = var.public_ip_ids[each.value.public_ip_names]
  }
  dynamic "ip_configuration" {
      for_each = each.value.additional_ip_configs
      content {
        name = ip_configuration.value.name
        subnet_id = try(ip_configuration.value.subnet_id, null)
        public_ip_address_id = var.public_ip_ids[ip_configuration.value.public_ip_name]
      }
    
  }
}

resource "azurerm_firewall_policy" "policy" {
  for_each            = var.firewall_config
  name                = each.value.policy_name
  location            = var.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.policy_sku
}

resource "azurerm_firewall_policy_rule_collection_group" "rule_group" {
  for_each = { for config_key, config_value in var.firewall_config : config_key => config_value.rule_collection_groups }

  name                   = each.value.name
  priority               = each.value.priority
  firewall_policy_id     = azurerm_firewall_policy.policy[each.key].id

  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collections
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          destination_addresses = try(rule.value.destination_addresses, null)
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = try(rule.value.fqdn_tags, null)

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type          = protocols.value.protocol_type
              port          = protocols.value.port
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collections
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
          protocols             = rule.value.protocols
        }
      }
    }
  }
}


