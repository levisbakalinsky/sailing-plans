# Deploy to a DigitalOcean Droplet (GitHub Actions)

CI builds `api` and `web` images, pushes them to GHCR, then SSHs into the Droplet and runs `docker compose up`.

## One-time Droplet setup

1. Create an Ubuntu 24.04 Droplet (e.g. `s-2vcpu-4gb` in `nyc1`) with your SSH key.
2. As root:

```bash
curl -fsSL https://raw.githubusercontent.com/levisbakalinsky/sailing-plans/main/deploy/bootstrap.sh | bash
# or copy deploy/bootstrap.sh up and run it
```

3. Place compose assets (the workflow also copies these on every deploy):

```bash
# from your laptop, after first bootstrap
scp deploy/docker-compose.yml deploy/Caddyfile root@DROPLET_IP:/opt/sailing-plans/
```

4. Edit secrets on the server:

```bash
nano /opt/sailing-plans/.env
chmod 600 /opt/sailing-plans/.env
```

## GitHub configuration

Create a GitHub Environment named **`production`** on the repo, and add these secrets:

| Secret | Value |
| --- | --- |
| `DROPLET_HOST` | Droplet public IP or hostname |
| `DROPLET_USER` | `root` (or a deploy user in the `docker` group) |
| `DROPLET_SSH_KEY` | Private key that can SSH to the Droplet |

Repo/workflow also uses `GITHUB_TOKEN` (automatic) to push/pull GHCR images.

After the first successful image push, confirm the GHCR packages `sailing-plans-api` and `sailing-plans-web` are visible to the Actions token (link to this repo; public or internal is simplest).

## Deploy

- Push to `main`, or
- Actions → **Deploy Droplet** → **Run workflow**

The workflow:

1. Builds and pushes `ghcr.io/<owner>/sailing-plans-api:<sha>` and `-web:<sha>` (+ `latest`)
2. Copies `deploy/docker-compose.yml` + `Caddyfile` to `/opt/sailing-plans`
3. Logs the Droplet into GHCR, pulls, restarts, curls `http://127.0.0.1/health`

## URLs

- Web: `http://<droplet-ip>/`
- API health: `http://<droplet-ip>/health`
- API under prefix: `http://<droplet-ip>/api/health`

## Local compose (optional)

From the repo root (build on your machine, not GHCR):

```bash
docker compose up --build
```
