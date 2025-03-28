variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

variable "subnet_ids" {
    type = map(string)
}

variable "private_endpoints" {
  description = "Map of private endpoint configurations."
  type = map(object({
    resource_group_name = string
    subnet_name           = string
    custom_network_interface_name = optional(string, null)
    private_dns_zone_group = optional(object({
      name       = string
      private_dns_zone_ids   = list(string)
    }), null)
    ip_configuration = optional(list(object({
      name              = string
      private_ip_address = optional(string, null)
      subresource_name  = optional(list(string), [])
      member_name        = optional(string, null)
    })), [])
    private_service_connection = list(object({
      name                           = string
      private_connection_resource_id = string
      is_manual_connection           = optional(bool, false)
      request_message                = optional(string, "")
      subresource_names              = optional(list(string), [])
    }))
  }))
}