output "autoscale_pool_id" {
  value = digitalocean_droplet_autoscale.this.id
}

output "loadbalancer_id" {
  value = try(digitalocean_loadbalancer.this[0].id, null)
}

output "loadbalancer_ip" {
  value = try(digitalocean_loadbalancer.this[0].ip, null)
}

output "pool_tag" {
  value = var.pool_tag
}

output "color_tag" {
  value = var.color_tag
}

output "app_url" {
  value = try("http://${digitalocean_loadbalancer.this[0].ip}/", null)
}

output "health_url" {
  value = try("http://${digitalocean_loadbalancer.this[0].ip}/health", null)
}

output "min_instances" {
  value = var.min_instances
}

output "max_instances" {
  value = var.max_instances
}
