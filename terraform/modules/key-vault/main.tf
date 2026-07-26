data "azurerm_client_config" "current" {}

variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "workload_identity_id" { type = string }
variable "workload_principal_id" { type = string }
variable "tags" { type = map(string) }

# Standard Key Vault is consumption-priced. No secrets are created by Terraform to avoid state leakage.
resource "azurerm_key_vault" "this" {
  name                          = replace("kv-${var.name_prefix}", "-", "")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_role_assignment" "secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.workload_principal_id
}

output "vault_uri" { value = azurerm_key_vault.this.vault_uri }
