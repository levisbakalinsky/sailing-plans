output "autoscale_pool_id" {
  value = module.app_pool.autoscale_pool_id
}

output "loadbalancer_id" {
  value = module.app_pool.loadbalancer_id
}

output "loadbalancer_ip" {
  value = module.app_pool.loadbalancer_ip
}

output "pool_tag" {
  value = module.app_pool.pool_tag
}

output "deploy_hosts_tag" {
  description = "Tag used by Deploy Development to find SSH targets."
  value       = module.app_pool.pool_tag
}

output "app_url" {
  value = module.app_pool.app_url
}

output "health_url" {
  value = module.app_pool.health_url
}

output "pool_min_instances" {
  value = module.app_pool.min_instances
}

output "pool_max_instances" {
  value = module.app_pool.max_instances
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

output "cloudflare_zone_ids" {
  value = module.cloudflare_dns.zone_ids
}

output "public_urls" {
  value = [
    for d in var.cloudflare_domains : "https://${d}/"
  ]
}
