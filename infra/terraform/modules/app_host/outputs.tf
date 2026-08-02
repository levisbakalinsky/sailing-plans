output "droplet_id" {
  description = "Droplet ID."
  value       = digitalocean_droplet.this.id
}

output "droplet_name" {
  description = "Droplet name."
  value       = digitalocean_droplet.this.name
}

output "ipv4_address" {
  description = "Public IPv4 address."
  value       = digitalocean_droplet.this.ipv4_address
}

output "ipv4_address_private" {
  description = "Private IPv4 address."
  value       = digitalocean_droplet.this.ipv4_address_private
}

output "urn" {
  description = "Droplet URN for project assignment."
  value       = digitalocean_droplet.this.urn
}

output "firewall_id" {
  description = "Cloud firewall ID."
  value       = digitalocean_firewall.this.id
}

output "region" {
  description = "Region slug."
  value       = digitalocean_droplet.this.region
}
