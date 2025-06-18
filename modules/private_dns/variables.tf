variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "vnet_ids" {
    type = map(string)
}

variable "dns_zones" {
    type = map(object({
      resource_group_name = string
      tags = optional(map(string))

      vnet_links = optional(
        map(object({
            vnet_name =  string
            registration_enabled = bool
        })), {} 
      )
      a_records = optional(
        map(object({
            ttl = number
            records = list(string)
        })), {}
      )
    }))
}