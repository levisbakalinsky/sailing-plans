#!/usr/bin/env bash
# Run once on a fresh Ubuntu Droplet as root.
set -euo pipefail

APP_DIR=/opt/sailing-plans

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gnupg

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

systemctl enable --now docker

mkdir -p "$APP_DIR"
cd "$APP_DIR"

if [[ ! -f .env ]]; then
  cat > .env <<'EOF'
POSTGRES_PASSWORD=change-me-now
DATABASE_URL=postgresql://postgres:change-me-now@db:5432/sailing_plans?schema=public
CLERK_SECRET_KEY=sk_test_replace_me
CLERK_PUBLISHABLE_KEY=pk_test_replace_me
NEXT_PUBLIC_API_URL=/api
API_IMAGE=ghcr.io/levisbakalinsky/sailing-plans-api:dev
WEB_IMAGE=ghcr.io/levisbakalinsky/sailing-plans-web:dev
APP_ENV=development
EOF
  chmod 600 .env
  echo "Wrote $APP_DIR/.env — edit secrets before first deploy."
fi

echo "Bootstrap complete. Copy deploy/docker-compose.yml and deploy/Caddyfile here, then run Actions → Deploy Development."
