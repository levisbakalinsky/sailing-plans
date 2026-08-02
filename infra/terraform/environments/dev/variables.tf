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
  type     = string
  default  = null
  nullable = true
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
