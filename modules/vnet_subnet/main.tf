# data "azurerm_ddos_protection_plan" "ddos_plan" {
#     for_each = { for k, v in var.vnets : k  => v.ddos_plan if v.ddos_plan != null }
#     name                = each.value.name
#     resource_group_name = each.value.resource_group
# }

resource "azurerm_virtual_network" "vnets" {
    for_each = var.vnets
    name = each.key
    location = var.location
    resource_group_name = each.value.resource_group_name
    address_space = each.value.address_space
    bgp_community = each.value.bgp_community
    dynamic "ddos_protection_plan" {
        for_each = try(each.value.ddos_plan != null, false) ? [each.value.ddos_plan] : []
        #for_each = each.value.ddos_protection_plan == null ? {} : {"iteration" : "1"}
        content {
          id = var.ddos[each.value.ddos_plan].id
          # id = data.azurerm_ddos_protection_plan.ddos_plan[each.key].id
          enable = each.value.ddos_protection_plan.enable
        }
    }

    tags = merge(each.value.tags, var.common_tags)
}

resource "azurerm_subnet" "subnet" {
  for_each = { for vnet_key, vnet_value in var.vnets : vnet_key => vnet_value.subnets }

  name                                  = each.value.key
  resource_group_name                   = var.vnets[each.key].resource_group_name
  virtual_network_name                  = azurerm_virtual_network.vnets[each.key].name
  address_prefixes                      = [each.value.value.address_prefix]
  service_endpoints                     = each.value.value.service_endpoints
  private_endpoint_network_policies     = each.value.value.private_endpoint_network_policies
}
