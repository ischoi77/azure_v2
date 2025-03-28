variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}

variable "storage_accounts" {
  description = "A map of storage account configurations. Each key represents the resource name."
  type = map(object({
    resource_group_name       = string
    #location                  = string
    account_tier              = string # Standard or Premium
    account_replication_type  = string # LRS, GRS, RAGRS, ZRS
    https_traffic_only_enabled = bool
    access_tier               = optional(string, null) # Hot or Cool (optional)
    account_kind              = optional(string, "StorageV2") # Storage, StorageV2, BlobStorage (optional)
    min_tls_version           = optional(string, "TLS1_2") # TLS1_0, TLS1_1, TLS1_2 (optional)

    nfsv3_enabled              = optional(bool, false)
    local_user_enabled         = optional(bool, true)
    sftp_enabled               = optional(bool, false)
    is_hns_enabled             = optional(bool, false)

    public_network_access_enabled  = optional(bool, false)   # Enable or disable public access to blobs (optional)
    large_file_share_enabled  = optional(bool, false)   # Enable or disable large file shares (optional)
    shared_access_key_enabled = optional(bool, true)    # Enable or disable shared access keys (optional)
    blob_properties           = optional(object({
      delete_retention_policy = optional(number, 7) # 1~365
      container_delete_retention_policy = optional(number, 7) # 1~365
    }), null)
    identity                  = optional(object({
      type = string # SystemAssigned, UserAssigned, SystemAssigned,UserAssigned
      identity_ids = optional(map(string), null) # For UserAssigned identities
    }), null)
    network_rules = optional(object({
      default_action             = optional(string, "Allow")   # Allow or Deny
      bypass                     = optional(list(string), []) # AzureServices, Logging, Metrics, None
      ip_rules                   = optional(list(string), []) # List of IP addresses or CIDR ranges
      virtual_network_subnet_names = optional(list(string), []) # List of subnet names to be resolved to IDs
      private_link_access        = optional(list(object({
        endpoint_resource_id = string
        endpoint_tenant_id   = string
      })), [])
    }), null)
    tags = optional(map(string), {})
  }))
}
