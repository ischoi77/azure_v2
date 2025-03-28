variable "traffic_manager_profiles" {
  description = "Map of Traffic Manager profiles with their configuration and endpoints"
  type = map(object({
    resource_group_name    = string
    profile_status         = string
    traffic_routing_method = string
    dns_config = object({
      relative_name = string
      ttl           = number
    })
    monitor_config = object({
      protocol                     = string
      port                         = number
      path                         = string
      interval_in_seconds          = number
      timeout_in_seconds           = number
      tolerated_number_of_failures = number
    })
    endpoints = map(object({
      target            = string
      endpoint_location = string
      priority          = number
      weight            = number
    }))
  }))
}


variable "common_tags" {
    type = map(string)
}
