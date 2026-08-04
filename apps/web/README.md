# Web (`@sailing-plans/web`)

Next.js App Router app. Auth UI is Clerk; API JWT verification lives in `@sailing-plans/api`.

```bash
# from repo root
pnpm --filter @sailing-plans/web dev
```

Defaults to [http://localhost:3000](http://localhost:3000). Copy `.env.example` → `.env.local` and set Clerk keys (see root wrap-up / Clerk dashboard).
