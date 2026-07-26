terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "name_prefix" {
  type    = string
  default = "abyportfolio"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# One-time cost: LRS storage has a small recurring charge based on stored state/operations.
resource "azurerm_resource_group" "state" {
  name     = "rg-${var.name_prefix}-tfstate"
  location = var.location
}

resource "azurerm_storage_account" "state" {
  # checkov:skip=CKV_AZURE_206 LRS is intentional for low-cost, reproducible Terraform state.
  # checkov:skip=CKV_AZURE_59 GitHub-hosted OIDC runners require the public endpoint; keys are disabled and the container is private.
  # checkov:skip=CKV_AZURE_33 Queue service is unused; only the private Blob container stores state.
  # checkov:skip=CKV2_AZURE_33 A private endpoint would prevent GitHub-hosted OIDC runners from reaching state.
  # checkov:skip=CKV2_AZURE_1 Platform-managed encryption is sufficient for non-secret Terraform state.
  name                            = "st${var.name_prefix}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy { days = 7 }
    container_delete_retention_policy { days = 7 }
  }
}

resource "azurerm_storage_container" "state" {
  # checkov:skip=CKV2_AZURE_21 State reads are audited through Azure activity logs; Storage Analytics requires shared keys.
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

output "backend" {
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state.name
    key                  = "portfolio/prod.tfstate"
  }
}
