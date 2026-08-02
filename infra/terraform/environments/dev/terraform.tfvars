project       = "sailing-plans"
environment   = "dev"
region        = "nyc1"
droplet_name  = "sailing-plans-app-dev"
droplet_size  = "s-2vcpu-4gb"
droplet_image = "ubuntu-24-04-x64"
# Existing default VPC in nyc1 (matches current Droplet).
vpc_uuid     = "6a3df577-cbc0-480c-93c6-7661ec01f19b"
ssh_key_name = "sailing-plans-do-deploy"
owner        = "platform"
cost_center  = "engineering"

# Open for GitHub-hosted Actions SSH deploys (key-only).
# When moving to a self-hosted runner or VPN, replace with e.g.:
#   ["76.87.105.2/32"]
allowed_ssh_cidrs = ["0.0.0.0/0", "::/0"]

db_cluster_name   = "sailing-plans-pg-dev"
db_engine_version = "18"
db_size           = "db-s-1vcpu-1gb"
db_name           = "sailing_plans"
db_app_user       = "sailing"
# Optional: add your public IP to run prisma migrate from a laptop.
# db_allowed_ip_addresses = ["1.2.3.4"]
db_allowed_ip_addresses = []
