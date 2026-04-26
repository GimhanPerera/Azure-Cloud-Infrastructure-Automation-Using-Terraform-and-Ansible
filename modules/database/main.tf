resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_db_port" {
  name                        = "allow-port-5432-for-db"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  
  # Allow only from Backend subnet
  source_address_prefix       = "10.0.2.0/24"
  destination_address_prefix  = "*"
  
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"

  # Allow only from Bastion subnet
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

resource "azurerm_network_interface" "db_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "backend_assoc" {
  network_interface_id      = azurerm_network_interface.db_nic.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.db_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.vm_name}-osdisk"
  }

  identity {
    type = "SystemAssigned"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  computer_name = var.vm_name
}