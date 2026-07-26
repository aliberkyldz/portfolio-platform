variable "domain_name" { type = string }
variable "ingress_ipv4" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }

# Azure DNS charges per hosted zone and DNS query; this replaces the need for Cloudflare.
resource "azurerm_dns_zone" "this" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_dns_txt_record" "ownership" {
  name                = "portfolio-verification"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record { value = "managed-by-terraform" }
}

resource "azurerm_dns_a_record" "apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.ingress_ipv4]
}

resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.ingress_ipv4]
}

output "name_servers" { value = azurerm_dns_zone.this.name_servers }
output "zone_name" { value = azurerm_dns_zone.this.name }
