resource "azurerm_private_endpoint" "this" {
  for_each             = var.private_endpoints
  name                 = each.key
  location             = var.location
  resource_group_name  = each.value.resource_group_name
  subnet_id            = var.subnet_ids[each.value.subnet_name]

  dynamic "private_service_connection" {
    for_each = each.value.private_service_connection
    content {
      name                            = private_service_connection.value.name
      private_connection_resource_id = private_service_connection.value.private_connection_resource_id
      is_manual_connection           = private_service_connection.value.is_manual_connection
      request_message                = private_service_connection.value.request_message
      subresource_names              = private_service_connection.value.subresource_names
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name    = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name  = ip_configuration.value.subresource_names
      member_name        = ip_configuration.value.member_name
    }
  }

  custom_network_interface_name = each.value.custom_network_interface_name

  tags = var.common_tags
}
