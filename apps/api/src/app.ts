import { Hono } from 'hono';
import type { HealthResponse } from '@sailing-plans/api-contract';

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

  app.notFound((c) => c.json({ error: 'Not Found' }, 404));

  return app;
}
