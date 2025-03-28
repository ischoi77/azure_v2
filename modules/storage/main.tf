
resource "azurerm_storage_account" "storage_accounts" {
  for_each                = var.storage_accounts
  name                    = each.key
  resource_group_name     = each.value.resource_group_name
  location                = var.location
  account_tier            = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  https_traffic_only_enabled = each.value.https_traffic_only_enabled

  account_kind             = lookup(each.value, "account_kind", "StorageV2")
  min_tls_version          = lookup(each.value, "min_tls_version", "TLS1_2")
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", false)
  large_file_share_enabled = lookup(each.value, "large_file_share_enabled", false)
  shared_access_key_enabled = lookup(each.value, "shared_access_key_enabled", true)
  #추가 속성
  nfsv3_enabled              = lookup(each.value, "nfsv3_enabled" , false)
  local_user_enabled         = lookup(each.value, "local_user_enabled", true)
  sftp_enabled               = lookup(each.value, "sftp_enabled", false)
  is_hns_enabled             = lookup(each.value, "is_hns_enabled", false)
  allow_nested_items_to_be_public = false
  
  dynamic "blob_properties" {
    for_each = each.value.blob_properties != null ? [each.value.blob_properties] : []
    content {
      delete_retention_policy {
          days = each.value.blob_properties.delete_retention_policy
      }
        container_delete_retention_policy {
          days = each.value.blob_properties.container_delete_retention_policy
      }
      
    }
  }

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  dynamic "network_rules" {
    for_each = each.value.network_rules != null ? [each.value.network_rules] : []
    content {
      default_action             = lookup(network_rules.value, "default_action", "Allow")
      bypass                     = lookup(network_rules.value, "bypass", [])
      ip_rules                   = lookup(network_rules.value, "ip_rules", [])
      virtual_network_subnet_ids = [for subnet_name in lookup(network_rules.value, "virtual_network_subnet_names", []) : var.subnet_ids[subnet_name]]
      #virtual_network_subnet_ids = lookup(network_rules.value, "virtual_network_subnet_ids", [])

      dynamic "private_link_access" {
        for_each = lookup(network_rules.value, "private_link_access", [])
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
        }
      }
    }
  }

  access_tier = lookup(each.value, "access_tier", null)

  tags = merge(var.common_tags, each.value.tags)
}