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
