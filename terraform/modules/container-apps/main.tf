variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "image" { type = string }
variable "min_replicas" { type = number }
variable "max_replicas" { type = number }
variable "log_analytics_workspace_id" {
  type    = string
  default = null
}
variable "tags" { type = map(string) }

resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${var.name_prefix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  logs_destination           = var.log_analytics_workspace_id == null ? "none" : "log-analytics"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app" "this" {
  name                         = "ca-${var.name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "portfolio"
      image  = var.image
      cpu    = 0.25
      memory = "0.5Gi"

      liveness_probe {
        transport = "HTTP"
        port      = 8080
        path      = "/healthz"
      }

      readiness_probe {
        transport = "HTTP"
        port      = 8080
        path      = "/healthz"
      }
    }

    http_scale_rule {
      name                = "http"
      concurrent_requests = 25
    }
  }

  ingress {
    external_enabled           = true
    allow_insecure_connections = false
    target_port                = 8080
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

output "id" { value = azurerm_container_app.this.id }
output "name" { value = azurerm_container_app.this.name }
output "environment_name" { value = azurerm_container_app_environment.this.name }
output "environment_static_ip" { value = azurerm_container_app_environment.this.static_ip_address }
output "fqdn" { value = azurerm_container_app.this.ingress[0].fqdn }
output "custom_domain_verification_id" {
  value     = azurerm_container_app_environment.this.custom_domain_verification_id
  sensitive = true
}
