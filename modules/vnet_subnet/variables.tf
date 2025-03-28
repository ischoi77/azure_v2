variable "common_tags" {
    type = map(string)
}

variable "ddos" {
    type = map(string)
}

variable "location" {
    type = string
}

variable "vnets" {
  description = "Map of configurations for multiple VNets and their Subnets"
  type = map(object({
    address_space       = list(string)
    location            = string
    resource_group_name = string
    tags = optional(map(string), {})
    ddos_plan = optional(object({
        name = string
      }), null)
    subnets = list(object({
      name           = string
      address_prefix = string
      service_endpoints = optional(list(string), [])
      private_endpoint_network_policies = optional(string, "Disabled")
    }))
  }))
}
