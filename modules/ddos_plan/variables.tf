variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "ddos_protection_plans" {
    type = map(object({
      resource_group_name = string
      tags                = optional(map(string))
    }))
}
