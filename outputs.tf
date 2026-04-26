output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}

output "backend_ip" {
  value = module.backend_vm.private_ip
}

output "database_ip" {
  value = module.database_vm.private_ip
}

output "bastion_ip" {
  value = module.bastion_vm.private_ip
}

output "bastion_public_ip" {
  value = module.bastion_vm.public_ip
}

output "App_public_URL" {
  value = module.frontend_container_app.container_app_url
}