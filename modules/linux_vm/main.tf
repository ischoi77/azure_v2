/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Linux VM 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/

data "azurerm_shared_image_version" "image_version" {
  for_each = { for k, v in var.vm_configurations : k => v if lookup(v, "source_image_reference", null) == null }

  name                = each.value.source_image.image_version
  image_name          = each.value.source_image.image_definition_name
  gallery_name        = each.value.source_image.gallery_name
  resource_group_name = each.value.source_image.resource_group_name
}




resource "azurerm_network_interface" "nic" {
  for_each = var.vm_configurations

  name                = lookup(each.value, "name", "${each.key}-nic-z${each.value.zones[0]}")
  location            = var.location
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.common_tags, each.value.tags)

  ip_configuration {
    name                          = "${each.key}-ipconfig"
    #subnet_id                     = each.value.network_interface.subnet_id
    subnet_id                     = var.subnet_ids[each.value.network_interface.subnet_name]
    private_ip_address            = lookup(each.value.network_interface, "private_ip_address", null)
    private_ip_address_allocation = each.value.network_interface.private_ip_address != null ? "Static" : "Dynamic"
    public_ip_address_id          = lookup(each.value.network_interface, "public_ip_address_id", null)
  }

}


resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = var.vm_configurations
  name                  = each.key
  resource_group_name   = each.value.resource_group_name
  location              = var.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  admin_password        = base64decode(each.value.admin_password)
  disable_password_authentication = each.value.disable_password_authentication
  #custom_data           = lookup(each.value, "custom_data", null)
  custom_data            = filebase64("${path.module}/user_data.sh")
  source_image_id       = lookup(each.value, "source_image_reference", null) == null ? data.azurerm_shared_image_version.image_version[each.key].id : null
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  tags                  = merge(var.common_tags, each.value.tags)        
  zone                  = each.value.zones[0]

  dynamic "source_image_reference" {
      for_each = lookup(each.value, "source_image_reference", null) == null ? [] : [each.value.source_image_reference]
      content {
        publisher = each.value.source_image_reference.publisher
        offer     = each.value.source_image_reference.offer
        sku       = each.value.source_image_reference.sku
        version   = each.value.source_image_reference.version          
      }
  }

  dynamic "identity" {
    for_each = lookup(each.value, "identity", null) == null ? [] : [each.value.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "UserAssigned" ? ["${var.user_assigned_identity_ids[identity.value.identity_name]}"] : try(identity.value.identity_ids, null)
      #identity_ids = identity.value.type == "UserAssigned" ? [lookup(identity.value.identity_name, var.user_assigned_identity_ids[identity.value.identity_name], [])] : [identity.value.identity_ids]
    }
  }
  
  os_disk {
    name                  = "${each.key}-OsDisk"
    caching               = lookup(each.value.os_disk, "caching", "ReadWrite")
    storage_account_type  = lookup(each.value.os_disk, "storage_account_type", "Standard_LRS")
    disk_size_gb          = lookup(each.value.os_disk, "disk_size_gb", 30)
  }
  lifecycle {
    ignore_changes = [ custom_data, admin_password ]
  }
}

# resource "azurerm_virtual_machine_extension" "vm_extension" {
#   for_each = { for vm_key, extensions in local.vm_extension_settings :
#     vm_key => extensions
#   }

#   name                 = each.value.name
#   virtual_machine_id   = local.vm_ids[each.key]
#   publisher            = each.value.publisher
#   type                 = each.value.type
#   type_handler_version = each.value.type_handler_version
#   auto_upgrade_minor_version = lookup(each.value, "auto_upgrade_minor_version", true)
#   settings             = each.value.settings
#   protected_settings   = lookup(each.value, "protected_settings", null)
# }



data "azurerm_managed_disk" "os_disk" {
  for_each            = var.vm_configurations
  name                = "${each.key}-OsDisk"
  resource_group_name = each.value.resource_group_name
}

resource "azapi_resource_action" "os_disk_sync" {
  for_each     = var.vm_configurations
  type         = "Microsoft.Compute/disks@2021-04-01" 
  resource_id  = data.azurerm_managed_disk.os_disk[each.key].id

  method = "PATCH"

  body = {
    tags = merge(var.common_tags, each.value.tags) 
  }
}