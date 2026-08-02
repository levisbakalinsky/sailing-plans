# syntax=docker/dockerfile:1

FROM node:24-bookworm-slim AS base
WORKDIR /app
ENV PNPM_HOME=/pnpm
ENV PATH=$PNPM_HOME:$PATH
RUN corepack enable \
  && apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

FROM base AS build
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/api/package.json apps/api/package.json
COPY packages/api-contract/package.json packages/api-contract/package.json
COPY packages/typescript-config packages/typescript-config
RUN pnpm install --filter @sailing-plans/api... --frozen-lockfile
COPY apps/api apps/api
COPY packages/api-contract packages/api-contract
# prisma.config.ts requires DATABASE_URL; generate does not connect.
ENV DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/sailing_plans?schema=public
RUN pnpm --filter @sailing-plans/api-contract build \
  && pnpm --filter @sailing-plans/api db:generate \
  && pnpm --filter @sailing-plans/api build \
  && pnpm --filter @sailing-plans/api deploy --prod --legacy /out \
  && cp apps/api/prisma.config.ts /out/prisma.config.ts \
  && cp -R apps/api/prisma /out/prisma

FROM node:24-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && useradd --system --uid 1001 api
COPY --from=build --chown=api:api /out/ ./
COPY --from=build --chown=api:api /app/apps/api/dist ./dist
USER api
EXPOSE 8080
CMD ["node", "dist/index.js"]
