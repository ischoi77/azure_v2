resource "azurerm_public_ip" "public_ips" {
    for_each            = var.public_ips
    name                = each.key
    location            = var.location
    resource_group_name = each.value.resource_group_name
    allocation_method   = "Static"
    sku                 = each.value.sku
    ddos_protection_mode = try(each.value.ddos_protection_mode, null)
    ddos_protection_plan_id = var.ddos[each.value.ddos_plan].id
    tags                = merge(var.common_tags, each.value.tags)
}