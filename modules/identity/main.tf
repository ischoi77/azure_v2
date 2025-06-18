resource "azurerm_user_assigned_identity" "user_assigned_identitys" {
    for_each = var.user_assigned_identities
    location            = var.location
    name                = each.key
    resource_group_name = each.value.resource_group_name
    tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_role_assignment" "role_assignment" {
    for_each = { for key, val in var.user_assigned_identities : key => val.roles }
    principal_id = azurerm_user_assigned_identity.user_assigned_identitys[key].principal_id
    scope = each.value[0].scope
    role_definition_name = each.value[0].role_definition_name
  
}


