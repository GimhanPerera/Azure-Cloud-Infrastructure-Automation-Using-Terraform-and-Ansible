location            = "East US"
environment         = "dev"
resource_group_name = "tier3-app"
subnets = {
  "bastion-subnet" = {
    address_prefix = "10.0.0.0/24"
  }

  "frontend-subnet" = {
    address_prefix = "10.0.1.0/24"
  }

  "backend-subnet" = {
    address_prefix = "10.0.2.0/24"
  }

  "db-subnet" = {
    address_prefix = "10.0.3.0/24"
  }
}
admin_username = "appuser"
admin_password = "Password@123"