locals {
  # inbound + outbound rules 하나로 합치기
  all_rules = flatten([
    for nsg_name, nsg_data in var.nsgs : concat(
        [
            # inbound rules
            for priority, rule in nsg_data.inbound : {
                priority                   = priority
                name                       = rule[0]
                direction                  = "Inbound"
                access                     = rule[1]
                protocol                   = rule[2]
                source_port_ranges         = rule[3]
                destination_port_ranges    = rule[4]
                source_address_prefix      = rule[5]
                destination_address_prefix = rule[6]
                description                = rule[7]
                nsg_name                   = nsg_name
                resource_group_name        = nsg_data.resource_group_name
                subnet_name                = nsg_data.subnet_name
                tags                       = nsg_data.tags
            }
        ],
        [
            # outbound rules
            for priority, rule in nsg_data.outbound : {
                priority                   = priority
                name                       = rule[0]
                direction                  = "Outbound"
                access                     = rule[1]
                protocol                   = rule[2]
                source_port_ranges         = rule[3]
                destination_port_ranges    = rule[4]
                source_address_prefix      = rule[5]
                destination_address_prefix = rule[6]
                description                = rule[7]
                nsg_name                   = nsg_name
                resource_group_name        = nsg_data.resource_group_name
                subnet_name                = nsg_data.subnet_name
                tags                       = nsg_data.tags
            }
        ]
    )
  ])

  # 서브넷 이름 vs 직접 CIDR 구분하여 처리
  processed_rules = [
    for r in local.all_rules : {
      priority                = r.priority
      name                    = r.name
      direction               = r.direction
      access                  = r.access
      protocol                = r.protocol
      source_port_ranges      = r.source_port_ranges
      destination_port_ranges = r.destination_port_ranges
      description             = r.description
      nsg_name                = r.nsg_name
      resource_group_name     = r.resource_group_name
      subnet_name             = r.subnet_name
      tags                    = r.tags

      # source_list, destination_list 각각에 대해:
      #  - 만약 subnet_address_prefixes 키에 있으면 subnet CIDR 목록
      #  - 없으면 그 문자열 자체를 CIDR로 간주
      source_cidrs = flatten([
        for item in r.source_list :
        contains(keys(var.subnet_address_prefixes), item)
          ? var.subnet_address_prefixes[item]
          : [item]
      ])

      destination_cidrs = flatten([
        for item in r.destination_list :
        contains(keys(var.subnet_address_prefixes), item)
          ? var.subnet_address_prefixes[item]
          : [item]
      ])
    }
  ]
}



resource "azurerm_network_security_group" "nsgs" {
    for_each = var.nsgs
    name =  each.key
    location = var.location
    resource_group_name = each.value.resource_group_name
    tags = merge(var.common_tags, each.value.tags)
}


resource "azurerm_subnet_network_security_group_association" "security_group_association" {
    for_each = var.nsgs
    subnet_id = var.subnet_ids[each.value.subnet_name] 
    network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
}



resource "azurerm_network_security_rule" "rules" {
    for_each = { for r in local.processed_rules : "${r.nsg_name}-${r.direction}-${r.priority}" => r }
    name                        = each.value.name
    priority                    = each.value.priority
    direction                   = each.value.direction
    access                      = each.value.access
    protocol                    = each.value.protocol
    source_port_range           = length(each.value.source_port_ranges) == 1 ? each.value.source_port_ranges[0] : null
    source_port_ranges          = length(each.value.source_port_ranges) > 1 ? each.value.source_port_ranges : null
    destination_port_range      = length(each.value.destination_port_ranges) == 1 ? each.value.destination_port_ranges[0] : null
    destination_port_ranges     = length(each.value.destination_port_ranges) > 1 ? each.value.destination_port_ranges : null
    source_address_prefix       = each.value.source_address_prefix
    destination_address_prefix  = each.value.destination_address_prefix
    description                 = each.value.description
    network_security_group_name = azurerm_network_security_group.nsgs[each.value.nsg_name].name
    resource_group_name         = azurerm_network_security_group.nsgs[each.value.nsg_name].resource_group_name
  
}
