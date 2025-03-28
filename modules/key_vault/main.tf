locals {
    key_vault_keys = flatten([
        for kv_name, kv_details in var.key_vaults : [
            for key_name, key_details in kv_details.keys : {
                key_vault_name = kv_name
                key_name       = key_name
                key_details    = key_details
            }
        ]
    ])
}


resource "azurerm_key_vault" "key_vaults" {
    for_each = var.key_vaults
    name = each.key
    location = var.location
    resource_group_name = each.value.resource_group_name
    sku_name = each.value.sku_name

    tenant_id = each.value.tenant_id

    enabled_for_disk_encryption     = true
    enabled_for_template_deployment = true
    enable_rbac_authorization       = true
    soft_delete_retention_days      = 90
    purge_protection_enabled        = false

    network_acls {
        bypass                     = lookup(each.value.network_acls, "bypass", "AzureService")
        default_action             = lookup(each.value.network_acls, "default_action", "Deny")
        virtual_network_subnet_ids = lookup(each.value.network_acls, "virtual_network_subnet_ids", [])
        ip_rules                   = lookup(each.value.network_acls, "ip_rules", [])
    }

    tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_key_vault_key" "keys" {
    for_each = { for key in local.key_vault_keys : "${key.key_vault_name}.${key.key_name}" => key }

    key_vault_id = azurerm_key_vault.key_vaults[each.value.key_vault_name].id
    name         = each.value.key_name
    key_type     = each.value.key_details.key_type

    key_opts     = each.value.key_details.key_opts
    tags         = merge(var.common_tags, each.value.key_details.tags)
}


