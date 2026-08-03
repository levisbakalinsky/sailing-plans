output "cluster_id" {
  value = digitalocean_database_cluster.this.id
}

output "cluster_urn" {
  value = digitalocean_database_cluster.this.urn
}

output "host" {
  value = digitalocean_database_cluster.this.host
}

output "private_host" {
  value = digitalocean_database_cluster.this.private_host
}

output "port" {
  value = digitalocean_database_cluster.this.port
}

output "user" {
  value = digitalocean_database_cluster.this.user
}

output "password" {
  value     = digitalocean_database_cluster.this.password
  sensitive = true
}

output "private_redis_url" {
  description = "Private REDIS_URL for Droplets (TLS via rediss://)."
  value       = digitalocean_database_cluster.this.private_uri
  sensitive   = true
}

output "public_redis_url" {
  description = "Public REDIS_URL for ops from allowed IPs."
  value       = digitalocean_database_cluster.this.uri
  sensitive   = true
}
