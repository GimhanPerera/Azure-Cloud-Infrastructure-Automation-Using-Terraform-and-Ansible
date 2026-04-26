output "container_app_url" {
  value = azurerm_container_app.frontend_app.latest_revision_fqdn
}

output "container_app_environment_id" {
  value = azurerm_container_app_environment.frontend_env.id
}