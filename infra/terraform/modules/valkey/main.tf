locals {
  standard_tags = distinct(concat(
    [
      var.project,
      var.environment,
      "managed-by:terraform",
      "role:valkey",
    ],
    var.tags,
  ))
}

resource "digitalocean_database_cluster" "this" {
  name                 = var.name
  engine               = "valkey"
  version              = var.engine_version
  size                 = var.size
  region               = var.region
  node_count           = var.node_count
  private_network_uuid = var.vpc_uuid
  eviction_policy      = var.eviction_policy
  tags                 = local.standard_tags
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
