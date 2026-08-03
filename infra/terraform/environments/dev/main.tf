data "digitalocean_ssh_key" "deploy" {
  name = var.ssh_key_name
}

locals {
  pool_tag  = "${var.project}-app-${var.environment}-pool"
  blue_tag  = "${local.pool_tag}-blue"
  green_tag = "${local.pool_tag}-green"
}

resource "digitalocean_tag" "pool" {
  name = local.pool_tag
}

resource "digitalocean_tag" "blue" {
  name = local.blue_tag
}

resource "digitalocean_tag" "green" {
  name = local.green_tag
}

module "postgres" {
  source = "../../modules/postgres"

  name                 = var.db_cluster_name
  environment          = var.environment
  project              = var.project
  region               = var.region
  engine_version       = var.db_engine_version
  size                 = var.db_size
  node_count           = 1
  vpc_uuid             = var.vpc_uuid
  database_name        = var.db_name
  app_user             = var.db_app_user
  droplet_ids          = []
  allowed_tags         = [local.pool_tag]
  allowed_ip_addresses = var.db_allowed_ip_addresses

  tags = [
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
  ]
}

module "valkey" {
  source = "../../modules/valkey"

  name                 = var.valkey_cluster_name
  environment          = var.environment
  project              = var.project
  region               = var.region
  engine_version       = var.valkey_engine_version
  size                 = var.valkey_size
  node_count           = 1
  vpc_uuid             = var.vpc_uuid
  droplet_ids          = []
  allowed_tags         = [local.pool_tag]
  allowed_ip_addresses = var.valkey_allowed_ip_addresses

  tags = [
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
  ]
}

# Active baseline color (starts as blue). Deploy workflow scales green up for cutover.
module "app_pool_blue" {
  source = "../../modules/app_pool"

  name                   = var.droplet_name
  environment            = var.environment
  project                = var.project
  region                 = var.region
  size                   = var.droplet_size
  image                  = var.droplet_image
  vpc_uuid               = var.vpc_uuid
  ssh_key_fingerprints   = [data.digitalocean_ssh_key.deploy.fingerprint]
  min_instances          = var.pool_min_instances
  max_instances          = var.pool_max_instances
  target_cpu_utilization = var.pool_target_cpu_utilization
  cooldown_minutes       = var.pool_cooldown_minutes
  pool_tag               = digitalocean_tag.pool.name
  color_tag              = digitalocean_tag.blue.name
  create_loadbalancer    = true
  create_firewall        = true
  allowed_ssh_cidrs      = var.allowed_ssh_cidrs
  database_url           = module.postgres.private_database_url
  redis_url              = module.valkey.private_redis_url
  ghcr_username          = var.ghcr_username
  ghcr_pull_token        = var.ghcr_pull_token
  api_image              = var.api_image
  web_image              = var.web_image
  compose_yaml           = file("${path.module}/../../../../deploy/docker-compose.yml")
  caddyfile              = file("${path.module}/../../../../deploy/Caddyfile")
  lb_size                = var.lb_size

  tags = [
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
  ]

  depends_on = [module.postgres, module.valkey]
}

# Opposite color pool. CI owns day-to-day create/delete around cutovers.
# WARNING: `terraform apply` will recreate this pool if CI deleted it — prefer
# Ops/Release for pool lifecycle; use TF apply mainly for LB/DB/DNS/tags.
module "app_pool_green" {
  source = "../../modules/app_pool"

  name                   = "${var.droplet_name}-green"
  environment            = var.environment
  project                = var.project
  region                 = var.region
  size                   = var.droplet_size
  image                  = var.droplet_image
  vpc_uuid               = var.vpc_uuid
  ssh_key_fingerprints   = [data.digitalocean_ssh_key.deploy.fingerprint]
  min_instances          = var.pool_min_instances
  max_instances          = var.pool_max_instances
  target_cpu_utilization = var.pool_target_cpu_utilization
  cooldown_minutes       = var.pool_cooldown_minutes
  pool_tag               = digitalocean_tag.pool.name
  color_tag              = digitalocean_tag.green.name
  create_loadbalancer    = false
  create_firewall        = false
  allowed_ssh_cidrs      = var.allowed_ssh_cidrs
  database_url           = module.postgres.private_database_url
  redis_url              = module.valkey.private_redis_url
  ghcr_username          = var.ghcr_username
  ghcr_pull_token        = var.ghcr_pull_token
  api_image              = var.api_image
  web_image              = var.web_image
  compose_yaml           = file("${path.module}/../../../../deploy/docker-compose.yml")
  caddyfile              = file("${path.module}/../../../../deploy/Caddyfile")
  lb_size                = var.lb_size

  tags = [
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
  ]

  depends_on = [module.postgres, module.valkey, module.app_pool_blue]
}

module "cloudflare_dns" {
  source = "../../modules/cloudflare_dns"

  domains          = var.cloudflare_domains
  origin_ipv4      = module.app_pool_blue.loadbalancer_ip
  proxied          = true
  ssl_mode         = "flexible"
  always_use_https = "on"
}
