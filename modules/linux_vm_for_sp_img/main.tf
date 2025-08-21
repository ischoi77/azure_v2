/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Specialized Image 사용 Linux VM 모듈 정의
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
    subnet_id                     = var.subnet_ids[each.value.network_interface.subnet_name]
    private_ip_address            = lookup(each.value.network_interface, "private_ip_address", null)
    private_ip_address_allocation = each.value.network_interface.private_ip_address != null ? "Static" : "Dynamic"
    public_ip_address_id          = lookup(each.value.network_interface, "public_ip_address_id", null)
  }
}

resource "azurerm_managed_disk" "managedDisk" {
  for_each              = var.vm_configurations
  name                 = "${each.key}-OsDisk"
  location             = var.location
  os_type              = "Linux"
  resource_group_name  = each.value.resource_group_name
  storage_account_type = lookup(each.value.os_disk, "storage_account_type", "Standard_LRS")
  create_option        = "FromImage"
  gallery_image_reference_id = lookup(each.value, "source_image_reference", null) == null ? data.azurerm_shared_image_version.image_version[each.key].id : null
  disk_size_gb         = lookup(each.value.os_disk, "disk_size_gb", 30)
  zone                 = each.value.zones[0]
  tags                 = merge(var.common_tags, each.value.tags)
  lifecycle {
    ignore_changes = [ hyper_v_generation ]
  }
}

resource "azurerm_virtual_machine" "vm" {
  for_each              = var.vm_configurations
  name                  = each.key
  resource_group_name   = each.value.resource_group_name
  location              = var.location
  vm_size               = each.value.size
  tags                  = merge(var.common_tags, each.value.tags)
  zones                 = each.value.zones

  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  dynamic "os_profile" {
    for_each = each.value.admin_username != null && each.value.admin_password != null ? [each.value] : []
    content {
      computer_name  = each.value.name
      admin_username = each.value.admin_username
      admin_password = each.value.admin_password
      custom_data    = lookup(each.value, "custom_data", null)
    }
  }

  dynamic "os_profile_linux_config" {
    for_each = each.value.admin_username != null && each.value.admin_password != null ? [each.value] : []
    content {
      disable_password_authentication = false
    }
  }

  storage_os_disk {
    name              = "${each.key}-OsDisk"
    os_type           = "Linux"
    managed_disk_id   = azurerm_managed_disk.managedDisk[each.key].id
    managed_disk_type = lookup(each.value.os_disk, "storage_account_type", "Standard_LRS")
    caching           = lookup(each.value.os_disk, "caching", "ReadWrite")
    create_option     = "Attach"
    # managed_disk_type = lookup(each.value.os_disk, "storage_account_type", "Standard_LRS")
    # disk_size_gb      = lookup(each.value.os_disk, "disk_size_gb", 30)
  }

  dynamic "identity" {
    for_each = lookup(each.value, "identity", null) == null ? [] : [each.value.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "UserAssigned" ? ["${var.user_assigned_identity_ids[identity.value.identity_name]}"] : try(identity.value.identity_ids, null)
      #identity_ids = identity.value.type == "UserAssigned" ? [lookup(each.value.identity, "identity_ids", var.user_assigned_identity_ids[identity.value.identity_name])] : null
    } 
  }

  dynamic "storage_image_reference" {
    for_each = lookup(each.value, "source_image_reference", null) == null ? [] : [each.value.source_image_reference]
    content {
      publisher = storage_image_reference.value.publisher
      offer     = storage_image_reference.value.offer
      sku       = storage_image_reference.value.sku
      version   = storage_image_reference.value.version
    }
  }
  # lifecycle {
  #   ignore_changes = [ identity, identity[0].identity_ids ]
  # }
}
