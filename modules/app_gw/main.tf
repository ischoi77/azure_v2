resource "azurerm_application_gateway" "application_gateways" {
    for_each            = var.application_gateways
    name                = each.key
    location            = each.value.location
    resource_group_name = each.value.resource_group_name
    sku {
        name = each.value.sku.name
        tier = each.value.sku.tier
        capacity = try(each.value.sku.capacity, null)
    }

    gateway_ip_configuration {
        name = each.value.gateway_ip_config.name
        subnet_id = var.subnet_ids[each.value.gateway_ip_config.subnet_name] 
    }

    dynamic "global" {
      for_each = try(each.value.global != null,false ) ? [each.value.global] : []
      content {
        request_buffering_enabled = each.value.global.request_buffering_enabled
        response_buffering_enabled = each.value.global.response_buffering_enabled
      }
      
    }

    dynamic "autoscale_configuration" {
        for_each = try(each.value.autoscale_configuration != null, false) ? [each.value.autoscale_configuration] : []
        content {
          min_capacity = each.value.autoscale_configuration.min_capacity
          max_capacity = each.value.autoscale_configuration.max_capacity          
        }
    }

    dynamic "waf_configuration" {
        for_each = try(each.value.waf_configuration != null, false) ? [each.value.waf_configuration] : []
        #for_each = each.value.waf_configuration == null ? {} : {"iteration" : "1"}
        content {
          enabled = each.value.waf_configuration.enable
          firewall_mode = each.value.waf_configuration.firewall_mode
          rule_set_version = each.value.waf_configuration.rule_set_version
        }
    }

    frontend_port {
      name = each.value.frontend_port.name
      port = each.value.frontend_port.port
    }

    gateway_ip_configuration {
      name = each.value.gateway_ip_config.name
      subnet_id = each.value.gateway_ip_config.subnet_id
    }

    frontend_ip_configuration {
      name = each.value.frontend_ip_config.name
      public_ip_address_id = var.public_ip_ids[each.value.frontend_ip_config.public_ip_name]
    }

    dynamic "backend_address_pool" {
      for_each = tomap(each.value.backend_pools)
      content {
        name         = backend_address_pool.value.name
      }
    }

    dynamic "backend_http_settings" {
      for_each = tomap(each.value.http_settings)
      content {
        name                  = backend_http_settings.value.name
        port                  = backend_http_settings.value.port
        protocol              = backend_http_settings.value.protocol
        request_timeout       = backend_http_settings.value.request_timeout
        cookie_based_affinity = backend_http_settings.value.cookie_based_affinity

        dynamic "connection_draining" {
          for_each = backend_http_settings.value.connection_drainin != null ? [backend_http_settings.value.connection_draining] : []
          content {
            enabled           = connection_draining.value.enabled
            drain_timeout_sec = connection_draining.value.drain_timeout_sec
          }
        }
      }
    }

    dynamic "http_listener" {
      for_each = tomap(each.value.listeners)
      content {
        name                           = http_listener.value.name
        frontend_ip_configuration_name = http_listener.value.frontend_ip_name
        frontend_port_name             = http_listener.value.frontend_port_name
        protocol                       = http_listener.value.protocol
        ssl_certificate_name           = try(http_listener.value.protocol, null)
      }
    }

    request_routing_rule {
      name = each.value.request_routing_rule.name
      rule_type = each.value.request_routing_rule.rule_type
      priority = each.value.request_routing_rule.priority
      http_listener_name = each.value.listeners.name
      backend_address_pool_name = each.value.backend_address_pool.name
      backend_http_settings_name = each.value.http_settings.name
    }

    dynamic "ssl_certificate" {
      for_each = try(each.value.ssl_certificate != null, false) ? [each.value.ssl_certificate] : []
      content {
        name = each.value.ssl_certificate.name
        data = try(each.value.ssl_certificate.data, null)
        password = try(each.value.ssl_certificate.password, null)
        key_vault_secret_id = try(each.value.ssl_certificate.key_vault_secret_id, null)
      }
    }


    tags = merge(var.common_tags, each.value.tags)
}


# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "app_gateway_backend_addr_pool_asso" {
    
# }



# resource "azurerm_public_ip" "ngrinder-appgw-public-ip" {
#   count               = local.ngrinder-appgw_generate[var.env][var.azure_region] ||  (var.env == "stg" && var.azure_region == "kc1") ? 1 : 0  # stg kc1 public ip 삭제 방지를 위한 임시 코드
#   name                = "${var.env}-${var.azure_region}-ngrinder-appgw-public-ip"
#   location            = azurerm_resource_group.azure-ops[count.index].location
#   resource_group_name = azurerm_resource_group.azure-ops[count.index].name
#   allocation_method   = "Static"
#   sku = "Standard"
# }


