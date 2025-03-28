
variable "vm_configurations" {
  description = "Map of VM configurations with extensions"
  type = map(object({
    #name                  = string
    resource_group_name   = string
    #location              = string
    size                  = string
    admin_username        = optional(string)
    admin_password        = optional(string)
    disable_password_authentication = optional(bool)
    zones                 = list(string)
    custom_data           = optional(string)
    tags                  = map(string)
    os_disk = optional(object({
        # name                  = string
        caching               = optional(string, "ReadWrite")
        storage_account_type  = optional(string, "Standard_LRS")
        disk_size_gb          = optional(number, 30)
    }))
    source_image = optional(object({
      gallery_name          = string
      image_definition_name = string
      image_version         = string
      resource_group_name   = string
    }))
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }))
    #source_image_id       = optional(string)
    network_interface     = object({
        name                          = optional(string, null)
        subnet_name                   = string
        private_ip_address            = optional(string, null)
        private_ip_address_allocation = optional(string, "Dynamic")
        public_ip_address_id          = optional(string, null)
    })
    identity              = optional(object({
      type         = optional(string)
      identity_ids = optional(list(string), [])
      identity_name = optional(string)
    }))
    extensions = list(object({
      name               = string
      publisher          = string
      type               = string
      type_handler_version = string
      auto_upgrade_minor_version = optional(bool, true)
      settings           = optional(map(any), {})
      protected_settings = optional(map(any), {})
    }))
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

variable "user_assigned_identity_ids" {
    type = map(string)
}