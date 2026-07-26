locals {
  name_prefix = "aby-portfolio-${var.environment}"
  tags        = merge(var.tags, { environment = var.environment })
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

# Standard static IPv4 is required by AKS Standard Load Balancer and prevents DNS drift.
resource "azurerm_public_ip" "ingress" {
  name                = "pip-${local.name_prefix}-ingress"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  domain_name_label   = replace(local.name_prefix, "-", "")
  tags                = local.tags
}

module "networking" {
  source              = "./modules/networking"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "observability" {
  source              = "./modules/observability"
  count               = var.enable_monitoring ? 1 : 0
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "aks" {
  source                     = "./modules/aks"
  name_prefix                = local.name_prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  subnet_id                  = module.networking.aks_subnet_id
  kubernetes_version         = var.kubernetes_version
  system_node_vm_size        = var.system_node_vm_size
  enable_spot_pool           = var.enable_spot_pool
  log_analytics_workspace_id = var.enable_monitoring ? module.observability[0].workspace_id : null
  tags                       = local.tags
}

module "identity" {
  source              = "./modules/identity"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  oidc_issuer_url     = module.aks.oidc_issuer_url
  tags                = local.tags
}

# Allows the AKS cloud controller to attach the Terraform-managed ingress IP.
resource "azurerm_role_assignment" "aks_ingress_ip" {
  scope                = azurerm_public_ip.ingress.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.control_plane_principal_id
}

module "key_vault" {
  source                = "./modules/key-vault"
  name_prefix           = local.name_prefix
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  workload_identity_id  = module.identity.id
  workload_principal_id = module.identity.principal_id
  tags                  = local.tags
}

module "dns" {
  source              = "./modules/dns"
  domain_name         = var.domain_name
  ingress_ipv4        = azurerm_public_ip.ingress.ip_address
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# Azure Portal dashboard has no separate service charge; underlying metric/log queries can be billable.
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
                value = module.aks.id
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  options = {
                    chart = {
                      metrics = [
                        {
                          resourceMetadata    = { id = module.aks.id }
                          name                = "node_cpu_usage_percentage"
                          aggregationType     = 4
                          namespace           = "microsoft.containerservice/managedclusters"
                          metricVisualization = { displayName = "Node CPU usage" }
                        },
                        {
                          resourceMetadata    = { id = module.aks.id }
                          name                = "node_memory_working_set_percentage"
                          aggregationType     = 4
                          namespace           = "microsoft.containerservice/managedclusters"
                          metricVisualization = { displayName = "Node memory working set" }
                        }
                      ]
                      title         = "AKS CPU and memory"
                      visualization = { chartType = 2 }
                    }
                  }
                }
              }
            }
          }
          "1" = {
            position = { x = 6, y = 0, colSpan = 6, rowSpan = 4 }
            metadata = {
              inputs = [{
                name  = "resourceId"
                value = module.aks.id
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  options = {
                    chart = {
                      metrics = [{
                        resourceMetadata    = { id = module.aks.id }
                        name                = "kube_pod_status_ready"
                        aggregationType     = 1
                        namespace           = "microsoft.containerservice/managedclusters"
                        metricVisualization = { displayName = "Ready pods" }
                      }]
                      title         = "Pod readiness"
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
