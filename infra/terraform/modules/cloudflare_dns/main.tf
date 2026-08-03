data "cloudflare_zone" "this" {
  for_each = toset(var.domains)
  name     = each.value
}

resource "cloudflare_record" "apex" {
  for_each = data.cloudflare_zone.this

  zone_id = each.value.id
  # Use the zone apex FQDN (not "@") so imports match Cloudflare's stored name.
  name    = each.key
  type    = "A"
  content = var.origin_ipv4
  proxied = var.proxied
  ttl     = 1
  comment = "managed-by:terraform sailing-plans"
}

resource "cloudflare_record" "www" {
  for_each = data.cloudflare_zone.this

  zone_id = each.value.id
  name    = "www"
  type    = "A"
  content = var.origin_ipv4
  proxied = var.proxied
  ttl     = 1
  comment = "managed-by:terraform sailing-plans"
}
