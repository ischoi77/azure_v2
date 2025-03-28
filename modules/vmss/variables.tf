variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "subnet_ids" {
    type = map(string)
}

variable "vmss_conifg" {
    type = map(object({
        resource_group_name = string
        size                = string
        admin_username      = string
        ssh_public_key      = string
        network_interface = list(object({
            subnet_id                     = string
            #tags                          = optional(map(string), {})
        }))
        os_disk = object({
          caching              = optional(string, "ReadWrite")
          storage_account_type = optional(string, "Standard_LRS")
          disk_size_gb         = optional(number, 30)
        })
        source_image_reference = optional(object({
            publisher = string
            offer     = string
            sku       = string
            version   = string
        }), null)
        source_image_id = optional(string, null)
        tags = map(string)
    }))
}