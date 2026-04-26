variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  default     = "webapp-vnet"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet definitions"
  type = map(object({
    address_prefix = string
  }))
}