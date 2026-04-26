output "vm_id" {
  value = azurerm_linux_virtual_machine.backend_vm.id
}

output "private_ip" {
  value = var.private_ip_address
}

output "principal_id" {
  value = azurerm_linux_virtual_machine.backend_vm.identity[0].principal_id
}
