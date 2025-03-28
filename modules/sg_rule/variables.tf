variable "nsgs" {
    type = map(object({
      resource_group_name = string
      subnet_name = string
      inbound_rules = map(list(any))
      outbound_rules = map(list(any))
      tags = map(string)
    }))
}

variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}

variable "subnet_address_prefixes" {
  type        = map(list(string))
}