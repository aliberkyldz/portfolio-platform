locals {
  name_prefix = "aby-portfolio-${var.environment}"
  tags        = merge(var.tags, { environment = var.environment })
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "observability" {
  source              = "./modules/observability"
  count               = var.enable_monitoring ? 1 : 0
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# Container Apps Consumption can scale to zero, avoiding the permanent VM and
# load-balancer cost of AKS for a low-traffic static portfolio.
module "container_apps" {
  source                     = "./modules/container-apps"
  name_prefix                = local.name_prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  image                      = var.container_image
  min_replicas               = var.min_replicas
  max_replicas               = var.max_replicas
  log_analytics_workspace_id = var.enable_monitoring ? module.observability[0].workspace_id : null
  tags                       = local.tags
}

module "dns" {
  source                        = "./modules/dns"
  domain_name                   = var.domain_name
  container_app_fqdn            = module.container_apps.fqdn
  container_app_environment_ip  = module.container_apps.environment_static_ip
  custom_domain_verification_id = module.container_apps.custom_domain_verification_id
  resource_group_name           = azurerm_resource_group.this.name
  tags                          = local.tags
}

# Azure Portal dashboards have no separate charge. Metric and Log Analytics
# queries can be billable, so ingestion is capped in the observability module.
resource "azurerm_portal_dashboard" "operations" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "dash-${local.name_prefix}-operations"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, colSpan = 6, rowSpan = 4 }
            metadata = {
              inputs = [{
                name  = "resourceId"
                value = module.container_apps.id
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  options = {
                    chart = {
                      metrics = [{
                        resourceMetadata    = { id = module.container_apps.id }
                        name                = "Requests"
                        aggregationType     = 1
                        namespace           = "microsoft.app/containerapps"
                        metricVisualization = { displayName = "HTTP requests" }
                      }]
                      title         = "Container App requests"
                      visualization = { chartType = 2 }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata = { model = {} }
  })
}
