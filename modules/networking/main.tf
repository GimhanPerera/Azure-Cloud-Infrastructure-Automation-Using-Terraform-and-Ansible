resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  dynamic "delegation" {
    for_each = each.key == "frontend-subnet" ? [1] : []

    content {
      name = "containerapp-delegation"

      service_delegation {
        name = "Microsoft.App/environments"

        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  }
}