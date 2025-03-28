variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
}

variable "common_tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "kubernetes_clusters" {
  description = "A map of Kubernetes cluster configurations. The key is the cluster name."
  type = map(
    object({
      resource_group_name = string
      dns_prefix          = string
      kubernetes_version  = optional(string, "1.25.6")
      node_pool = object({
        vm_size       = string
        node_count    = optional(number, 1)
        os_disk_size  = optional(number, 30)
        max_pods      = optional(number, 110)
        type          = optional(string, "VirtualMachineScaleSets")
      })
      additional_node_pools = optional(map(
        object({
          vm_size       = string
          node_count    = optional(number, 1)
          os_disk_size  = optional(number, 30)
          max_pods      = optional(number, 110)
          type          = optional(string, "VirtualMachineScaleSets")
        })
      ), {})
      identity = optional(object({
        type = string
      }), { type = "SystemAssigned" })
      network_profile = optional(object({
        network_plugin = string
        network_policy = optional(string, "calico")
        dns_service_ip = optional(string, "10.0.0.10")
        service_cidr   = optional(string, "10.0.0.0/16")
        docker_bridge_cidr = optional(string, "172.17.0.1/16")
      }), null)
      tags = optional(map(string), {})
    })
  )
}
