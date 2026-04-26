resource "azurerm_container_app_environment" "frontend_env" {
  name                       = var.container_app_environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name

  infrastructure_subnet_id   = var.frontend_subnet_id

  internal_load_balancer_enabled = false

  zone_redundancy_enabled = false
}

resource "azurerm_container_app" "frontend_app" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.frontend_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      image  = var.frontend_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "BACKEND_API"
        value = var.backend_api_url
      }
    }

    min_replicas = 1
    max_replicas = 1
  }

  ingress {
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"
    allow_insecure_connections = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}