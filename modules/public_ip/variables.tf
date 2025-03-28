variable "public_ips" {
    type = map(object({
      location            = string
      resource_group_name = string
      sku                 = string
      tags                = map(string)
    }))
}

variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "ddos" {
    type = map(string)
}
