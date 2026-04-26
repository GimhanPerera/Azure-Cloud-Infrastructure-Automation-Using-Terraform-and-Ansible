terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tier3apptfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}