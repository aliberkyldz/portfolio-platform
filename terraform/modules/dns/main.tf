variable "domain_name" { type = string }
variable "container_app_fqdn" { type = string }
variable "container_app_environment_ip" { type = string }
variable "custom_domain_verification_id" {
  type      = string
  sensitive = true
}
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }

# Azure DNS is sufficient for authoritative DNS. Cloudflare is optional and is
# intentionally omitted to keep the request path and operating model simple.
resource "azurerm_dns_zone" "this" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_dns_a_record" "apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.container_app_environment_ip]
}

resource "azurerm_dns_txt_record" "apex_verification" {
  name                = "asuid"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = var.custom_domain_verification_id
  }
}

resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.container_app_fqdn
}

resource "azurerm_dns_txt_record" "www_verification" {
  name                = "asuid.www"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = var.custom_domain_verification_id
  }
}

output "name_servers" { value = azurerm_dns_zone.this.name_servers }
output "zone_name" { value = azurerm_dns_zone.this.name }
