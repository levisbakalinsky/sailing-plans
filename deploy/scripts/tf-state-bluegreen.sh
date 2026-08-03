#!/usr/bin/env bash
# ONE-TIME helper: Terraform state moves for the blue/green app_pool refactor.
# Already applied in production; kept for disaster recovery only.
# Run from infra/terraform/environments/dev after terraform init.
set -euo pipefail

list="$(terraform state list)"

if grep -qx 'module.app_pool.digitalocean_droplet_autoscale.this' <<<"$list"; then
  echo "Moving module.app_pool → module.app_pool_blue"
  terraform state mv 'module.app_pool' 'module.app_pool_blue'
  list="$(terraform state list)"
fi

if grep -qx 'module.app_pool_blue.digitalocean_loadbalancer.this' <<<"$list"; then
  terraform state mv \
    'module.app_pool_blue.digitalocean_loadbalancer.this' \
    'module.app_pool_blue.digitalocean_loadbalancer.this[0]'
  list="$(terraform state list)"
fi

if grep -qx 'module.app_pool_blue.digitalocean_firewall.this' <<<"$list"; then
  terraform state mv \
    'module.app_pool_blue.digitalocean_firewall.this' \
    'module.app_pool_blue.digitalocean_firewall.this[0]'
  list="$(terraform state list)"
fi

if grep -qx 'module.app_pool_blue.digitalocean_tag.pool' <<<"$list"; then
  terraform state mv \
    'module.app_pool_blue.digitalocean_tag.pool' \
    'digitalocean_tag.pool'
fi

echo "Blue/green state migrate complete."
