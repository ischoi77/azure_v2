variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}


variable "route_tables" {
    type = map(object({
      resource_group_name = string
      subnet_name = string
      bgp_route_propagation_enabled = optional(bool)

    }))
  
}