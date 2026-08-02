data "digitalocean_ssh_key" "deploy" {
  name = var.ssh_key_name
}

module "app_host" {
  source = "../../modules/app_host"

  name               = var.droplet_name
  environment        = var.environment
  project            = var.project
  region             = var.region
  size               = var.droplet_size
  image              = var.droplet_image
  vpc_uuid           = var.vpc_uuid
  ssh_key_ids        = [data.digitalocean_ssh_key.deploy.id]
  monitoring         = true
  ipv6               = false
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  allowed_http_cidrs = ["0.0.0.0/0", "::/0"]

  tags = [
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
  ]
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
  droplet_ids          = [tostring(module.app_host.droplet_id)]
  allowed_ip_addresses = var.db_allowed_ip_addresses

  tags = [
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
  ]
}
