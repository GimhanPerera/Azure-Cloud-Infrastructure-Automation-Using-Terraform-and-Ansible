output "vm_id" {
  value = azurerm_linux_virtual_machine.bastion_vm.id
}

output "private_ip" {
  value = var.private_ip_address
}

output "public_ip" {
  description = "Public IP address of the Bastion VM"
  value       = azurerm_public_ip.bastion_pip.ip_address
}