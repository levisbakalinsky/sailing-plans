variable "project" {
  type    = string
  default = "sailing-plans"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "nyc1"
}

variable "droplet_name" {
  type    = string
  default = "sailing-plans-app-dev"
}

variable "droplet_size" {
  type    = string
  default = "s-2vcpu-4gb"
}

variable "droplet_image" {
  type    = string
  default = "ubuntu-24-04-x64"
}

variable "vpc_uuid" {
  description = "VPC UUID shared by the autoscale pool, LB, and managed Postgres."
  type        = string
}

variable "ssh_key_name" {
  description = "Name of an existing DigitalOcean SSH key."
  type        = string
  default     = "sailing-plans-do-deploy"
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0", "::/0"]
}

variable "owner" {
  description = "Team or individual accountable for this environment."
  type        = string
  default     = "platform"
}

variable "cost_center" {
  type    = string
  default = "engineering"
}

variable "db_cluster_name" {
  type    = string
  default = "sailing-plans-pg-dev"
}

variable "db_engine_version" {
  type    = string
  default = "18"
}

variable "db_size" {
  description = "Managed Postgres size slug (DEV default is smallest)."
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "db_name" {
  type    = string
  default = "sailing_plans"
}

variable "db_app_user" {
  type    = string
  default = "sailing"
}

variable "db_allowed_ip_addresses" {
  description = "Extra IPs trusted by the managed DB firewall (ops/migrate)."
  type        = list(string)
  default     = []
}

variable "pool_min_instances" {
  type    = number
  default = 2
}

variable "pool_max_instances" {
  type    = number
  default = 4
}

variable "pool_target_cpu_utilization" {
  type    = number
  default = 0.7
}

variable "pool_cooldown_minutes" {
  type    = number
  default = 10
}

variable "lb_size" {
  type    = string
  default = "lb-small"
}

variable "ghcr_username" {
  type    = string
  default = "levisbakalinsky"
}

variable "ghcr_pull_token" {
  description = "GHCR token for Droplet image pulls on boot (set via TF_VAR_ghcr_pull_token / CI secret)."
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

variable "cloudflare_domains" {
  description = "Cloudflare zones whose apex + www point at the Load Balancer."
  type        = list(string)
  default = [
    "sailingplans.com",
    "sailingplans.net",
    "sailingplans.org",
    "sailingplans.us",
  ]
}
