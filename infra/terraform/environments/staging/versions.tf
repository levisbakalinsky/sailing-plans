terraform {
  required_version = ">= 1.5.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.60"
    }
  }

  # Remote state on DigitalOcean Spaces (S3-compatible).
  # Credentials via AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (Spaces keys).
  backend "s3" {}
}
