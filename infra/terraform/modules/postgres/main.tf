locals {
  standard_tags = distinct(concat(
    [
      var.project,
      var.environment,
      "managed-by:terraform",
      "role:postgres",
    ],
    var.tags,
  ))
}

resource "digitalocean_database_cluster" "this" {
  name                 = var.name
  engine               = "pg"
  version              = var.engine_version
  size                 = var.size
  region               = var.region
  node_count           = var.node_count
  private_network_uuid = var.vpc_uuid
  tags                 = local.standard_tags
}

resource "digitalocean_database_db" "app" {
  cluster_id = digitalocean_database_cluster.this.id
  name       = var.database_name
}

resource "digitalocean_database_user" "app" {
  cluster_id = digitalocean_database_cluster.this.id
  name       = var.app_user

  # DO may return empty settings blocks after engine upgrades; avoid churn.
  lifecycle {
    ignore_changes = [settings]
  }
}

resource "digitalocean_database_firewall" "this" {
  cluster_id = digitalocean_database_cluster.this.id

  dynamic "rule" {
    for_each = var.droplet_ids
    content {
      type  = "droplet"
      value = rule.value
    }
  }

  dynamic "rule" {
    for_each = var.allowed_tags
    content {
      type  = "tag"
      value = rule.value
    }
  }

  dynamic "rule" {
    for_each = var.allowed_ip_addresses
    content {
      type  = "ip_addr"
      value = rule.value
    }
  }
}
