module "resource_group" {
  source = "./modules/resource-group"

  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
    project     = "tier3-app"
  }
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location            = var.location

  vnet_name           = "webapp-vnet"
  vnet_address_space  = ["10.0.0.0/16"]

  subnets = var.subnets
}

data "azurerm_client_config" "current" {}

module "backend_vm" {
  source = "./modules/backend-vm"

  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.networking.subnet_ids["backend-subnet"]

  admin_username      = var.admin_username
  admin_password      = var.admin_password

  key_vault_id        = module.keyvault.key_vault_id
}

module "database_vm" {
  source = "./modules/database"

  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.networking.subnet_ids["db-subnet"]

  admin_username      = var.admin_username
  admin_password      = var.admin_password

  key_vault_id        = module.keyvault.key_vault_id
}

module "bastion_vm" {
  source = "./modules/bastion-vm"

  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.networking.subnet_ids["bastion-subnet"]

  admin_username      = var.admin_username
  admin_password      = var.admin_password
}

module "keyvault" {
  source = "./modules/keyvault"

  name                = "tier3-app-kv"
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "backend_kv_access" {
  scope        = module.keyvault.key_vault_id
  principal_id = module.backend_vm.principal_id

  role_definition_name = "Key Vault Secrets User"
}

resource "azurerm_role_assignment" "database_kv_access" {
  scope                = module.keyvault.key_vault_id
  principal_id         = module.database_vm.principal_id

  role_definition_name = "Key Vault Secrets User"
}

module "frontend_container_app" {
  source = "./modules/frontend-container-app"

  resource_group_name = module.resource_group.name
  location            = var.location

  container_app_environment_name = "frontend-container-env"
  container_app_name             = "frontend-con-app"

  frontend_image = "gimhan764/tier3-app-1-frontend:v1"

  backend_api_url = "http://10.0.2.4:5000/api/fruits"

  frontend_subnet_id = module.networking.subnet_ids["frontend-subnet"]
}