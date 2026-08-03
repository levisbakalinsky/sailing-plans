variable "name" {
  description = "Autoscale pool name."
  type        = string
}

variable "environment" {
  type = string
}

variable "project" {
  type    = string
  default = "sailing-plans"
}

variable "region" {
  type = string
}

variable "size" {
  type = string
}

variable "image" {
  type    = string
  default = "ubuntu-24-04-x64"
}

variable "vpc_uuid" {
  type = string
}

variable "ssh_key_fingerprints" {
  description = "SSH key fingerprints for pool Droplets."
  type        = list(string)
}

variable "min_instances" {
  type    = number
  default = 2
}

variable "max_instances" {
  type    = number
  default = 4
}

variable "target_cpu_utilization" {
  type    = number
  default = 0.7
}

variable "cooldown_minutes" {
  type    = number
  default = 10
}

variable "pool_tag" {
  description = "Tag applied to pool Droplets and used by the Load Balancer / DB firewall."
  type        = string
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0", "::/0"]
}

variable "database_url" {
  description = "Private DATABASE_URL injected into Droplet user-data."
  type        = string
  sensitive   = true
}

variable "redis_url" {
  description = "Private REDIS_URL (Valkey) injected into Droplet user-data."
  type        = string
  sensitive   = true
  default     = ""
}

variable "ghcr_username" {
  type    = string
  default = "levisbakalinsky"
}

variable "ghcr_pull_token" {
  description = "Token used by Droplets to pull GHCR images on boot."
  type        = string
  sensitive   = true
  default     = ""
}

variable "api_image" {
  type    = string
  default = "ghcr.io/levisbakalinsky/sailing-plans-api:dev"
}

variable "web_image" {
  type    = string
  default = "ghcr.io/levisbakalinsky/sailing-plans-web:dev"
}

variable "compose_yaml" {
  description = "Contents of docker-compose.yml for cloud-init."
  type        = string
}

variable "caddyfile" {
  description = "Contents of Caddyfile for cloud-init."
  type        = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "lb_size" {
  description = "Load balancer size slug."
  type        = string
  default     = "lb-small"
}
