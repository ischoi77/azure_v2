variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}

variable "nic_ids_map" {
    type = map(string)
}

variable "asgs" {
    type = map(object({
      resource_group_name = string
      tags                = optional(map(string), {})
      attach_nic_names    = optional(list(string), [])
    }))
}