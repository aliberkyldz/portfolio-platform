variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }

# Log ingestion is usage-priced. 30-day retention and a 1 GB/day cap bound accidental spend.
resource "azurerm_log_analytics_workspace" "this" {
  name                       = "log-${var.name_prefix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = "PerGB2018"
  retention_in_days          = 30
  daily_quota_gb             = 1
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  tags                       = var.tags
}

# Workspace-based Application Insights; static frontend uses platform/ingress telemetry.
resource "azurerm_application_insights" "this" {
  name                = "appi-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

output "workspace_id" { value = azurerm_log_analytics_workspace.this.id }
