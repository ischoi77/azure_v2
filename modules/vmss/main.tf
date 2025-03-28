resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
    for_each = var.vmss_conifg

    name                = each.key
    location            = var.location
    resource_group_name = each.value.resource_group_name
    #size                = each.value.size
    admin_username      = each.value.admin_username
    sku                 = each.value.sku
    instances           = each.value.instances
    
    network_interface {
      name = "${each.key}-nic"
      primary = true
      # enable_accelerated_networking = ""
      # network_security_group_id = ""

      ip_configuration {
        name = "${each.key}-ipconfig"
        primary = true
        subnet_id = each.value.subnet_id
        # application_gateway_backend_address_pool_ids = ""
        # application_security_group_ids = ""
        # load_balancer_backend_address_pool_ids = ""
      }
    }

    admin_ssh_key {
      username      = each.value.admin_username
      public_key    = each.value.ssh_public_key
    }
    os_disk {
      caching               = lookup(each.value.os_disk, "caching", "ReadWrite")
      storage_account_type  = lookup(each.value.os_disk, "storage_account_type", "Standard_LRS")
      disk_size_gb          = lookup(each.value.os_disk, "disk_size_gb", 30)
    }

    source_image_id = each.value.source_image_id

    dynamic "source_image_reference" {
        for_each = each.value.source_image_id == null ? [1] : []
        content {
          publisher = each.value.source_image_reference.publisher
          offer     = each.value.source_image_reference.offer
          sku       = each.value.source_image_reference.sku
          version   = each.value.source_image_reference.version          
        }
      
    }

    tags = merge(var.common_tags, each.value.tags)
  
}

