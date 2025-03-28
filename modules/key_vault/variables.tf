
variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "key_vaults" {
    type = map(object({
      resource_group_name = string
      sku_name            = string
      tenant_id           = string
      tags                = map(string)

      network_acls = object({
        bypass                     = optional(string, "AzureService")
        default_action             = optional(string, "Deny")
        virtual_network_subnet_ids = optional(list(string), [])
        ip_rules                   = optional(list(string), [])
      })
      keys = map(object({
        key_type = string
        key_opts = list(string)
        tags     = map(string)
      }))
    }))
  
}