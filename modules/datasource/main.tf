/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure DataSource 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/



data "azurerm_user_assigned_identity" "existing_identities" {
  for_each = var.user_assigned_identities

  name                = each.key
  resource_group_name = each.value
}


data "azurerm_subnet" "existing_subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
}


data "azurerm_virtual_machine" "vm" {
  for_each = { for idx, vm in local.vm_info : "${vm.resource_group}-${vm.name}" => vm }

  name                = each.value.name
  resource_group_name = each.value.resource_group
}

data "azurerm_managed_disk" "vm_osdisk" {
  for_each = { for idx, vm in local.vm_info : "${vm.resource_group}-${vm.name}" => vm }

  name = "${each.value.name}-OsDisk"
  resource_group_name = each.value.resource_group
}


data "azurerm_network_interface" "nic" {
  for_each = { for idx, nic in local.nic_info : "${nic.resource_group}-${nic.name}" => nic }

  name                = each.value.name
  resource_group_name = each.value.resource_group
}


data "azurerm_storage_account" "storage" {
  for_each = { for idx, sa in local.storage_info : "${sa.resource_group}-${sa.name}" => sa }

  name                = each.value.name
  resource_group_name = each.value.resource_group
}


data "azurerm_storage_containers" "containers" {
  for_each = { for idx, sa in local.storage_info : "${sa.resource_group}-${sa.name}" => sa }
  storage_account_id = data.azurerm_storage_account.storage[each.key].id
}