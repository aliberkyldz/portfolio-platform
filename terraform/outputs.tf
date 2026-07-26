output "aks_cluster_name" { value = module.aks.name }
output "resource_group_name" { value = azurerm_resource_group.this.name }
output "dns_name_servers" { value = module.dns.name_servers }
output "key_vault_uri" { value = module.key_vault.vault_uri }
output "workload_identity_client_id" { value = module.identity.client_id }
output "ingress_public_ip" { value = azurerm_public_ip.ingress.ip_address }

output "next_steps" {
  value = <<-EOT
    1. Delegate ${var.domain_name} at the registrar to the dns_name_servers output.
    2. Install the Helm chart, then point apex A record to the ingress public IP.
    3. Add GitHub environment secrets documented in README.md.
  EOT
}
