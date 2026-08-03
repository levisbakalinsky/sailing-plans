variable "name" {
  description = "Managed database cluster name."
  type        = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "engine_version" {
  description = "Postgres major version."
  type        = string
  default     = "18"
}

variable "size" {
  description = "DigitalOcean database size slug."
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "vpc_uuid" {
  description = "VPC for private networking (should match the app Droplet)."
  type        = string
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "sailing_plans"
}

variable "app_user" {
  description = "Application database user."
  type        = string
  default     = "sailing"
}

variable "droplet_ids" {
  description = "Droplet IDs allowed to connect (trusted sources)."
  type        = list(string)
  default     = []
}

variable "allowed_tags" {
  description = "Droplet tags allowed to connect (for autoscale pools)."
  type        = list(string)
  default     = []
}

variable "allowed_ip_addresses" {
  description = "Extra IPv4/IPv6 addresses allowed to connect (ops/migrate)."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = list(string)
  default = []
}
