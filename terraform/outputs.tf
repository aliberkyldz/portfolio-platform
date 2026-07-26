output "resource_group_name" { value = azurerm_resource_group.this.name }
output "container_app_name" { value = module.container_apps.name }
output "container_app_environment_name" { value = module.container_apps.environment_name }
output "container_app_fqdn" { value = module.container_apps.fqdn }
output "dns_name_servers" { value = module.dns.name_servers }

output "next_steps" {
  value = <<-EOT
    1. Delegate ${var.domain_name} at the registrar to the dns_name_servers output.
    2. Bind ${var.domain_name} and www.${var.domain_name} with Azure managed certificates.
    3. Run the release workflow to deploy an immutable Docker Hub image.
  EOT
}
