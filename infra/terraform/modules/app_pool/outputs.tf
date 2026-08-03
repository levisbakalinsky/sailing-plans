output "autoscale_pool_id" {
  value = digitalocean_droplet_autoscale.this.id
}

output "loadbalancer_id" {
  value = digitalocean_loadbalancer.this.id
}

output "loadbalancer_ip" {
  value = digitalocean_loadbalancer.this.ip
}

output "pool_tag" {
  value = var.pool_tag
}

output "app_url" {
  value = "http://${digitalocean_loadbalancer.this.ip}/"
}

output "health_url" {
  value = "http://${digitalocean_loadbalancer.this.ip}/health"
}

output "min_instances" {
  value = var.min_instances
}

output "max_instances" {
  value = var.max_instances
}
