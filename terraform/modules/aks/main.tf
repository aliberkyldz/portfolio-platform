variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "system_node_vm_size" { type = string }
variable "enable_spot_pool" { type = bool }
variable "log_analytics_workspace_id" {
  type    = string
  default = null
}
variable "tags" { type = map(string) }

# AKS Free tier avoids the control-plane SLA fee. The VM and managed disks remain billable.
resource "azurerm_kubernetes_cluster" "this" {
  name                              = "aks-${var.name_prefix}"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = "aks-${var.name_prefix}"
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = "Free"
  local_account_disabled            = true
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  azure_policy_enabled              = true

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = 1
    auto_scaling_enabled         = false
    vnet_subnet_id               = var.subnet_id
    os_disk_size_gb              = 30
    only_critical_addons_enabled = false
    upgrade_settings { max_surge = "10%" }
  }

  identity { type = "SystemAssigned" }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [1]
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}

# Spot is isolated to a user pool because AKS system pools cannot use Spot priority.
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  count                 = var.enable_spot_pool ? 1 : 0
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.system_node_vm_size
  vnet_subnet_id        = var.subnet_id
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = -1
  node_count            = 1
  auto_scaling_enabled  = false
  mode                  = "User"
  node_labels           = { workload = "spot" }
  node_taints           = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  os_disk_size_gb       = 30
  tags                  = var.tags
}

output "name" { value = azurerm_kubernetes_cluster.this.name }
output "id" { value = azurerm_kubernetes_cluster.this.id }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.this.oidc_issuer_url }
output "control_plane_principal_id" { value = azurerm_kubernetes_cluster.this.identity[0].principal_id }
