/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Private DNS 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/

resource "azurerm_private_dns_zone" "zone" {
    for_each = var.dns_zones

    name = each.key
    resource_group_name = each.value.resource_group_name
    tags =  merge(var.common_tags, each.value.tags)
  
}

locals {
    all_vnet_links = flatten([
        for zone_key, zone_val in var.dns_zones : [
            for link_name, link_data in zone_val.vnet_links : {
                zone_key = zone_key
                link_name = link_name
                link_data = link_data
            }
        ]
    ])
    all_a_records = flatten([
        for zone_key, zone_val in var.dns_zones : [
            for record_key, record_data in zone_val.a_records : {
                zone_key   = zone_key
                record_key = record_key 
                ttl        = record_data.ttl 
                records    = record_data.records 
            }
        ]
    ])
}


resource "azurerm_private_dns_zone_virtual_network_link" "zone_link" {
    for_each = {
      for item in local.all_vnet_links : 
      "${item.zone.key}-${item.link_name}" => item
    }
    name = each.value.link_name
    resource_group_name = var.dns_zones[each.value.zone_key].resource_group_name
    private_dns_zone_name = azurerm_private_dns_zone.zone[each.value.zone_key].name

    registration_enabled = each.value.link_data.registration_enabled
    virtual_network_id = var.vnet_ids[each.value.link_data.vnet_name]
  
}


resource "azurerm_private_dns_a_record" "a_records" {
    for_each = {
      for item in local.all_a_records : 
      "${item.zone_key}-${item.record_key}" => item 
    }
    name                = each.value.record_key
    resource_group_name = var.dns_zones[each.value.zone_key].resource_group_name
    zone_name           = azurerm_private_dns_zone.zone[each.value.zone_key].name
    ttl                 = each.value.ttl
    records             = each.value.records
  
}

