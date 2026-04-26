variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "East US"
}

variable "container_app_environment_name" {
  type    = string
  default = "frontend-container-env"
}

variable "container_app_name" {
  type    = string
  default = "frontend-con-app"
}

variable "frontend_image" {
  type    = string
  default = "gimhan764/tier3-app-1-frontend:v1"
}

variable "backend_api_url" {
  type    = string
  default = "http://10.0.2.4:5000/api/fruits"
}

variable "frontend_subnet_id" {
  type = string
}