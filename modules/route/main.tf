/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Route  모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/

locals {
  route_rules = flatten([
    for rt_name, rt_data in var.route_tables : [
        for route_name, rule in rt_data.routes : {
            route_table_name       = rt_name
            resource_group_name    = rt_data.resource_group_name
            route_name             = route_name 
            address_prefix         = rule.address_prefix 
            next_hop_type          = rule.next_hop_type
            next_hop_in_ip_address = lookup(rule, "next_hop_in_ip_address", null)
        }
    ]
  ])
}

resource "azurerm_route_table" "route_tables" {
    for_each = var.route_tables

    name = each.key
    location = var.location
    resource_group_name = each.value.resource_group_name

    tags = merge(var.common_tags, each.value.tags)

    bgp_route_propagation_enabled = try(each.value.bgp_route_propagation_enabled, null)

}

resource "azurerm_subnet_route_table_association" "associations" {
    for_each = { for rt_name, rt_data in var.route_tables : rt_name => rt_data }

    subnet_id = var.subnet_ids[each.value.subnet_name]
    route_table_id = azurerm_route_table.route_tables[each.key].id
}


resource "azurerm_route" "routes" {
    for_each = { for rule in local.local.route_rules : "${rule.route_table_name}-${rule.route_name}" => rule }

    name                    = each.value.route_name
    address_prefix          = each.value.address_prefix
    next_hop_type           = each.value.next_hop_type
    next_hop_in_ip_address  = try(each.value.next_hop_in_ip_address, null)

    resource_group_name     = each.value.resource_group_name
    route_table_name        = azurerm_route_table.route_tables[each.value.route_table_name].name
}

