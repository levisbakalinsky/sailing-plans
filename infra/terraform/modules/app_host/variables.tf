variable "name" {
  description = "Droplet name (also used as a stable identifier in tags)."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string
}

variable "project" {
  description = "Project key used for cost allocation and tagging."
  type        = string
  default     = "sailing-plans"
}

variable "region" {
  description = "DigitalOcean region slug."
  type        = string
}

variable "size" {
  description = "Droplet size slug."
  type        = string
}

variable "image" {
  description = "Droplet image slug."
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "vpc_uuid" {
  description = "VPC UUID. Null uses the region default VPC."
  type        = string
  default     = null
}

variable "ssh_key_ids" {
  description = "SSH key IDs to inject into the Droplet."
  type        = list(string)
}

variable "tags" {
  description = "Additional tags beyond the standard set."
  type        = list(string)
  default     = []
}

variable "monitoring" {
  description = "Enable DigitalOcean monitoring agent."
  type        = bool
  default     = true
}

variable "ipv6" {
  description = "Enable IPv6."
  type        = bool
  default     = false
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH (port 22)."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP/HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}
