variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "oidc_issuer_url" { type = string }
variable "tags" { type = map(string) }

# Managed identity itself has no direct charge and removes long-lived Azure credentials from pods.
resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-${var.name_prefix}-workload"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "portfolio" {
  name                = "fic-portfolio"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.workload.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:portfolio:portfolio"
}

output "id" { value = azurerm_user_assigned_identity.workload.id }
output "client_id" { value = azurerm_user_assigned_identity.workload.client_id }
output "principal_id" { value = azurerm_user_assigned_identity.workload.principal_id }
