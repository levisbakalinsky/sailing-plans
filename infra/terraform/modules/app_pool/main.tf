locals {
  droplet_tags = distinct(concat(
    [
      var.project,
      var.environment,
      "managed-by:terraform",
      "role:app-host",
      var.pool_tag,
      var.color_tag,
    ],
    var.tags,
  ))

  env_file = <<-EOT
    DATABASE_URL=${var.database_url}
    REDIS_URL=${var.redis_url}
    CLERK_SECRET_KEY=sk_test_replace_me
    CLERK_PUBLISHABLE_KEY=pk_test_replace_me
    NEXT_PUBLIC_API_URL=/api
    API_IMAGE=${var.api_image}
    WEB_IMAGE=${var.web_image}
    APP_ENV=development
  EOT

  boot_script = <<-EOT
    #!/usr/bin/env bash
    set -euo pipefail
    APP_DIR=/opt/sailing-plans
    cd "$APP_DIR"

    if ! command -v docker >/dev/null 2>&1; then
      curl -fsSL https://get.docker.com | sh
      systemctl enable --now docker
    fi

    if [[ -n "${var.ghcr_pull_token}" ]]; then
      echo "${var.ghcr_pull_token}" | docker login ghcr.io -u "${var.ghcr_username}" --password-stdin
    fi

    # Private GHCR images may be unavailable until GHCR_PULL_TOKEN is set or Deploy Development runs.
    docker compose pull || echo "compose pull failed; waiting for CI deploy"
    docker compose up -d --remove-orphans || echo "compose up failed; waiting for CI deploy"

    for i in $(seq 1 36); do
      if curl -fsS http://127.0.0.1/health >/dev/null; then
        exit 0
      fi
      sleep 5
    done
    docker compose logs --tail=100 || true
    echo "bootstrap finished without healthy /health; CI deploy can complete the stack"
    exit 0
  EOT

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    compose_yaml_b64 = base64encode(var.compose_yaml)
    caddyfile_b64    = base64encode(var.caddyfile)
    env_file_b64     = base64encode(local.env_file)
    boot_script_b64  = base64encode(local.boot_script)
  })
}

resource "digitalocean_droplet_autoscale" "this" {
  name = var.name

  config {
    min_instances          = var.min_instances
    max_instances          = var.max_instances
    target_cpu_utilization = var.target_cpu_utilization
    cooldown_minutes       = var.cooldown_minutes
  }

  droplet_template {
    size               = var.size
    region             = var.region
    image              = var.image
    ssh_keys           = var.ssh_key_fingerprints
    vpc_uuid           = var.vpc_uuid
    tags               = local.droplet_tags
    user_data          = local.user_data
    ipv6               = false
    with_droplet_agent = true
  }

  # Deploy workflow scales inactive color up/down around cutover.
  lifecycle {
    ignore_changes = [
      config,
    ]
  }
}

resource "digitalocean_loadbalancer" "this" {
  count = var.create_loadbalancer ? 1 : 0

  name     = "${var.name}-lb"
  region   = var.region
  size     = var.lb_size
  vpc_uuid = var.vpc_uuid

  forwarding_rule {
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    protocol                 = "http"
    port                     = 80
    path                     = "/health"
    check_interval_seconds   = 10
    response_timeout_seconds = 5
    unhealthy_threshold      = 3
    healthy_threshold        = 2
  }

  # Initial attachment; deploy workflow flips this between blue/green color tags.
  droplet_tag = var.color_tag

  lifecycle {
    ignore_changes = [droplet_tag]
  }

  depends_on = [digitalocean_droplet_autoscale.this]
}

resource "digitalocean_firewall" "this" {
  count = var.create_firewall ? 1 : 0

  name = "${var.name}-fw"
  # Shared pool tag so both colors get the same SSH/HTTP rules.
  tags = [var.pool_tag]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.allowed_ssh_cidrs
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
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
