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

