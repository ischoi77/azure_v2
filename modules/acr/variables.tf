// variables.tf

variable "acr_config" {
  description = "Configuration for Azure Container Registries"
  type = map(object({
    resource_group_name                 = string
    sku                                 = string
    admin_enabled                       = optional(bool, false)
    tags                                = optional(map(string), {})
    acr_pe_tags                         = optional(map(string), {})
    retention_policy_enabled           = optional(bool, false)
    retention_policy_days              = optional(number)
    quarantine_policy_enabled          = optional(bool, false)
    trust_policy_enabled               = optional(bool, false)
    encryption_enabled                 = optional(bool, false)
    encryption_key_vault_key_id        = optional(string)
    encryption_identity_client_id      = optional(string)
    identity              = optional(object({
      type         = string
      identity_ids = optional(string)
    }))
    public_network_access_enabled      = optional(bool, true)
    private_endpoint_enabled = optional(bool, false) # ✅ Private Endpoint 활성화 여부
    subnet_name               = optional(string, null) # ✅ Private Endpoint가 속할 서브넷 Name
    private_dns_zone_id     = optional(string, null) # ✅ Private DNS Zone ID
    custom_network_interface_name = optional(string, null) # ✅ Private Endpoint NIC name
    vnet_name               = optional(string, null) # ✅ private DNS virtualnetwork link 용 vnet 이름 
    vnet_resource_group_name = optional(string, null) # ✅ private DNS virtualnetwork link 용 vnet RG 이름

    network_rule_set        = object({
      default_action = string
      ip_rules       = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    })
  }))
}

variable "location" {
  description = "Default location for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "user_assigned_identity_ids" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}