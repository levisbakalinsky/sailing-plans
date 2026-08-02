# Build context: repository root (see infra/digitalocean/app.yaml).
FROM node:22-bookworm-slim AS base
WORKDIR /app
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS build
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/api/package.json ./apps/api/
COPY packages/api-contract/package.json ./packages/api-contract/
COPY packages/typescript-config ./packages/typescript-config
RUN pnpm install --frozen-lockfile
COPY apps/api ./apps/api
COPY packages/api-contract ./packages/api-contract
RUN pnpm --filter @sailing-plans/api-contract build \
  && pnpm --filter @sailing-plans/api db:generate \
  && pnpm --filter @sailing-plans/api build

FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080
RUN groupadd --system --gid 1001 nodejs \
  && useradd --system --uid 1001 --gid nodejs api \
  && corepack enable
COPY --from=build /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=build /app/apps/api/package.json ./apps/api/
COPY --from=build /app/apps/api/dist ./apps/api/dist
COPY --from=build /app/apps/api/prisma ./apps/api/prisma
COPY --from=build /app/packages/api-contract/package.json ./packages/api-contract/
COPY --from=build /app/packages/api-contract/dist ./packages/api-contract/dist
COPY --from=build /app/packages/api-contract/openapi.json ./packages/api-contract/openapi.json
COPY --from=build /app/packages/typescript-config ./packages/typescript-config
RUN pnpm install --frozen-lockfile --prod \
  && pnpm --filter @sailing-plans/api exec prisma generate \
  && chown -R api:nodejs /app
USER api
EXPOSE 8080
WORKDIR /app/apps/api
CMD ["node", "dist/index.js"]
