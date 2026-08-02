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

output "database_name" {
  value = digitalocean_database_db.app.name
}

output "app_user" {
  value = digitalocean_database_user.app.name
}

output "app_password" {
  value     = digitalocean_database_user.app.password
  sensitive = true
}

output "private_database_url" {
  description = "Prisma-friendly private URI for the Droplet (ssl required)."
  value = format(
    "postgresql://%s:%s@%s:%s/%s?sslmode=require&schema=public",
    digitalocean_database_user.app.name,
    urlencode(digitalocean_database_user.app.password),
    digitalocean_database_cluster.this.private_host,
    digitalocean_database_cluster.this.port,
    digitalocean_database_db.app.name,
  )
  sensitive = true
}

output "public_database_url" {
  description = "Prisma-friendly public URI for ops/migrate from allowed IPs."
  value = format(
    "postgresql://%s:%s@%s:%s/%s?sslmode=require&schema=public",
    digitalocean_database_user.app.name,
    urlencode(digitalocean_database_user.app.password),
    digitalocean_database_cluster.this.host,
    digitalocean_database_cluster.this.port,
    digitalocean_database_db.app.name,
  )
  sensitive = true
}
