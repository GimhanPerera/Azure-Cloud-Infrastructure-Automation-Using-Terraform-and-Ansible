variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_name" {
  type    = string
  default = "database-vm"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "private_ip_address" {
  type    = string
  default = "10.0.3.4"
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "key_vault_id" {
  type = string
}