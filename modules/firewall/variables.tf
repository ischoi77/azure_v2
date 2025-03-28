variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}


variable "subnet_ids" {
    type = map(string)
}

variable "public_ip_ids" {
    type = map(string)  
}

variable "firewall_config" {
  description = "Configuration for Azure Firewall, Firewall Policy, and Rule Collection Group"
  type = map(object({
    location              = string
    resource_group_name   = string
    firewall_name         = string
    policy_name           = string
    public_ip_names       = list(string) # List of public IP names to match with outputs from public_ip module
    additional_ip_configs = list(object({
      name      = string
      subnet_id = string
      public_ip_name = string
    }))
    rule_collection_groups = list(object({
      name       = string
      priority   = number
      application_rule_collections = optional(list(object({
        name     = string
        priority = number
        action   = string
        rules = list(object({
          name                   = string
          source_addresses       = list(string)
          destination_addresses  = optional(list(string))
          destination_fqdns      = list(string)
          fqdn_tags              = optional(list(string))
          protocols = list(object({
            protocol_type = string
            port          = string
          }))
        }))
      })), [])
      network_rule_collections = optional(list(object({
        name     = string
        priority = number
        action   = string
        rules = list(object({
          name                   = string
          source_addresses       = list(string)
          destination_addresses  = list(string)
          destination_ports      = list(string)
          protocols              = list(string)
        }))
      })), [])
    }))
  }))
}
