variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Base name for resource group"
  type        = string
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}