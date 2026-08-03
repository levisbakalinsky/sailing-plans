output "autoscale_pool_id_blue" {
  value = module.app_pool_blue.autoscale_pool_id
}

output "autoscale_pool_id_green" {
  value = module.app_pool_green.autoscale_pool_id
}

output "loadbalancer_id" {
  value = module.app_pool_blue.loadbalancer_id
}

output "loadbalancer_ip" {
  value = module.app_pool_blue.loadbalancer_ip
}

output "pool_tag" {
  value = module.app_pool_blue.pool_tag
}

output "blue_tag" {
  value = module.app_pool_blue.color_tag
}

output "green_tag" {
  value = module.app_pool_green.color_tag
}

output "deploy_hosts_tag" {
  description = "Shared tag for finding either color (DB firewall / ops)."
  value       = module.app_pool_blue.pool_tag
}

output "app_url" {
  value = module.app_pool_blue.app_url
}

output "health_url" {
  value = module.app_pool_blue.health_url
}

output "pool_min_instances" {
  value = module.app_pool_blue.min_instances
}

output "pool_max_instances" {
  value = module.app_pool_blue.max_instances
}

output "db_cluster_id" {
  value = module.postgres.cluster_id
}

output "db_private_host" {
  value = module.postgres.private_host
}

output "db_public_host" {
  value = module.postgres.host
}

output "db_port" {
  value = module.postgres.port
}

output "db_name" {
  value = module.postgres.database_name
}

output "db_app_user" {
  value = module.postgres.app_user
}

output "database_url_private" {
  description = "Private DATABASE_URL (also injected into pool user-data)."
  value       = module.postgres.private_database_url
  sensitive   = true
}

output "database_url_public" {
  description = "Ops/migrate URI (requires DB firewall IP allow)."
  value       = module.postgres.public_database_url
  sensitive   = true
}

output "valkey_cluster_id" {
  value = module.valkey.cluster_id
}

output "valkey_private_host" {
  value = module.valkey.private_host
}

output "valkey_public_host" {
  value = module.valkey.host
}

output "valkey_port" {
  value = module.valkey.port
}

output "redis_url_private" {
  description = "Private REDIS_URL (also injected into pool user-data)."
  value       = module.valkey.private_redis_url
  sensitive   = true
}

output "redis_url_public" {
  description = "Ops REDIS_URL (requires Valkey firewall IP allow)."
  value       = module.valkey.public_redis_url
  sensitive   = true
}

output "cloudflare_zone_ids" {
  value = module.cloudflare_dns.zone_ids
}

output "public_urls" {
  value = [
    for d in var.cloudflare_domains : "https://${d}/"
  ]
}
