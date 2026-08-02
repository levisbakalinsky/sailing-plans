# Build context: repository root (see infra/digitalocean/app.yaml).
FROM node:22-bookworm-slim AS base
WORKDIR /app
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && corepack enable

FROM base AS build
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/api/package.json ./apps/api/
COPY packages/api-contract/package.json ./packages/api-contract/
COPY packages/typescript-config ./packages/typescript-config
RUN pnpm install --frozen-lockfile
COPY apps/api ./apps/api
COPY packages/api-contract ./packages/api-contract
ENV CI=true
RUN pnpm --filter @sailing-plans/api-contract build \
  && pnpm --filter @sailing-plans/api db:generate \
  && pnpm --filter @sailing-plans/api build

FROM base AS runner
ENV NODE_ENV=production
ENV PORT=8080
RUN groupadd --gid 1001 nodejs \
  && useradd --uid 1001 --gid nodejs --create-home api
COPY --from=build --chown=api:nodejs /app /app
USER api
EXPOSE 8080
WORKDIR /app/apps/api
CMD ["node", "dist/index.js"]
