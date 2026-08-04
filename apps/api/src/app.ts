import { Hono } from 'hono';
import type { HealthResponse } from '@sailing-plans/api-contract';
import { meRoutes } from './routes/me.js';

export function createApp() {
  const app = new Hono();

  app.get('/health', (c) => {
    const body: HealthResponse = {
      status: 'ok',
      service: 'sailing-plans-api',
      timestamp: new Date().toISOString(),
    };

    return c.json(body);
  });

  // Authenticated app API — Clerk JWT required (see /me).
  app.route('/me', meRoutes);

  app.notFound((c) => c.json({ error: 'Not Found' }, 404));

  return app;
}
