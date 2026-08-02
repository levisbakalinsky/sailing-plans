locals {
  standard_tags = distinct(concat(
    [
      var.project,
      var.environment,
      "managed-by:terraform",
      "role:app-host",
    ],
    var.tags,
  ))

  # DigitalOcean firewalls allow at most 5 tags.
  firewall_tags = slice(local.standard_tags, 0, min(length(local.standard_tags), 5))
}

resource "digitalocean_droplet" "this" {
  name       = var.name
  region     = var.region
  size       = var.size
  image      = var.image
  vpc_uuid   = var.vpc_uuid
  monitoring = var.monitoring
  ipv6       = var.ipv6
  ssh_keys   = var.ssh_key_ids
  tags       = local.standard_tags

  # App bootstrap is handled by deploy/bootstrap.sh + GitHub Actions.
  # Avoid user_data here so imports/applies do not force Droplet replacement.
  lifecycle {
    ignore_changes = [
      # Image slug vs ID drift after import.
      image,
      # SSH key attachment is not safely mutable in-place on DO; set at create time.
      ssh_keys,
    ]
  }
}


resource "digitalocean_firewall" "this" {
  name        = "${var.name}-fw"
  droplet_ids = [digitalocean_droplet.this.id]
  tags        = local.firewall_tags

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.allowed_ssh_cidrs
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = var.allowed_http_cidrs
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = var.allowed_http_cidrs
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
