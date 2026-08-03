variable "domains" {
  description = "Zones to point at the origin (apex + www)."
  type        = list(string)
}

variable "origin_ipv4" {
  description = "Origin IPv4 (DigitalOcean Load Balancer)."
  type        = string
}

variable "proxied" {
  description = "Orange-cloud proxy through Cloudflare."
  type        = bool
  default     = true
}

# Kept for call-site compatibility / docs; SSL is configured once in Cloudflare
# (flexible + always HTTPS) because the DO LB currently terminates HTTP only.
variable "ssl_mode" {
  type    = string
  default = "flexible"
}

variable "always_use_https" {
  type    = string
  default = "on"
}
