terraform {
  required_version = ">= 1.5.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.60"
    }
  }

  # Default: local state (gitignored). For shared/remote state, copy
  # backend.hcl.example → backend.hcl and re-init:
  #   terraform init -backend-config=backend.hcl -migrate-state
  #
  # backend "s3" {}
}
