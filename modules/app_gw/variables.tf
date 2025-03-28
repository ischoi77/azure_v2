variable "application_gateways" {
    type = map(object({
      location            = string
      resource_group_name = string
      tags                = map(string)
      sku                 = object({
        name     = string
        tier     = string
        capacity = optional(number)
      })
      autoscale_configuration = optional(object({
        min_capacity = number
        max_capacity = optional(number, 2)
      }))

      waf_configuration = optional(object({
        enabled = bool
        firewall_mode = string
        role_set_type = optional(string)
        rule_set_version = string
      }))
      
      frontend_port = object({
        name = string
        port = number
      })
      gateway_ip_config = object({
        name      = string
        subnet_name = string
      })
      frontend_ip_config = object({
        name           = string
        public_ip_name = string
      })
      backend_pools = map(object({
        name    = string
        targets = optional(list(string))
      }))
      http_settings = map(object({
        name                  = string
        port                  = number
        protocol              = string
        request_timeout       = number
        cookie_based_affinity = string
        connection_draining = map(object({
          enabled = bool
          drain_timeout_sec = number
        }))
      }))
      listeners = map(object({
        name               = string
        frontend_ip_name   = string
        frontend_port_name = number
        protocol           = string
        ssl_certificate_name = optional(string)
      }))
      request_routing_rule = map(object({
        name      = string
        rule_type = string
        priority  = number
      }))
    }))
}

variable "public_ip_ids" {
    type = map(string)  
}


variable "common_tags" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}

