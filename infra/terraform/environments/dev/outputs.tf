output "droplet_id" {
  value = module.app_host.droplet_id
}

output "droplet_name" {
  value = module.app_host.droplet_name
}

output "ipv4_address" {
  value = module.app_host.ipv4_address
}

output "firewall_id" {
  value = module.app_host.firewall_id
}

output "deploy_host" {
  description = "Value for GitHub secret DROPLET_HOST."
  value       = module.app_host.ipv4_address
}

output "app_url" {
  value = "http://${module.app_host.ipv4_address}/"
}

output "health_url" {
  value = "http://${module.app_host.ipv4_address}/health"
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
  description = "Set as DATABASE_URL on the Droplet (/opt/sailing-plans/.env)."
  value       = module.postgres.private_database_url
  sensitive   = true
}

output "database_url_public" {
  description = "Ops/migrate URI (requires DB firewall IP allow)."
  value       = module.postgres.public_database_url
  sensitive   = true
}
