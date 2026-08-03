variable "name" {
  description = "Managed Valkey cluster name."
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
  description = "Valkey major version."
  type        = string
  default     = "8"
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
  description = "VPC for private networking (should match the app pool)."
  type        = string
}

variable "eviction_policy" {
  description = "Valkey eviction policy."
  type        = string
  default     = "allkeys_lru"
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
  description = "Extra IPv4/IPv6 addresses allowed to connect (ops)."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = list(string)
  default = []
}
