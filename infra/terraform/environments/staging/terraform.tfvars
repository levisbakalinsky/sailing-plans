project       = "sailing-plans"
environment   = "staging"
region        = "nyc1"
droplet_name  = "sailing-plans-app-staging"
droplet_size  = "s-2vcpu-4gb"
droplet_image = "ubuntu-24-04-x64"
vpc_uuid      = "6a3df577-cbc0-480c-93c6-7661ec01f19b"
ssh_key_name  = "sailing-plans-do-deploy"
owner         = "platform"
cost_center   = "engineering"

# Keep open while using GitHub-hosted Actions SSH deploys.
allowed_ssh_cidrs = ["0.0.0.0/0", "::/0"]
