output "zone_ids" {
  value = { for k, z in data.cloudflare_zone.this : k => z.id }
}

output "apex_fqdns" {
  value = { for k, r in cloudflare_record.apex : k => r.hostname }
}

output "www_fqdns" {
  value = { for k, r in cloudflare_record.www : k => r.hostname }
}
