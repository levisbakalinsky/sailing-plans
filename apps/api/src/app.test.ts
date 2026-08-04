import { describe, expect, it } from 'vitest';
import type { HealthResponse } from '@sailing-plans/api-contract';
import { createApp } from './app.js';

describe('GET /health', () => {
  it('returns ok status payload', async () => {
    const app = createApp();
    const response = await app.request('/health');
    const body = (await response.json()) as HealthResponse;

    expect(response.status).toBe(200);
    expect(body.status).toBe('ok');
    expect(body.service).toBe('sailing-plans-api');
    expect(typeof body.timestamp).toBe('string');
  });
});

describe('GET /me', () => {
  it('rejects unauthenticated requests', async () => {
    // Clerk validates publishable key shape (base64 frontend API + '$').
    process.env.CLERK_PUBLISHABLE_KEY =
      'pk_test_' +
      Buffer.from('helpful-fox-12.clerk.accounts.dev$')
        .toString('base64')
        .replace(/=+$/, '');
    process.env.CLERK_SECRET_KEY = 'sk_test_' + 'x'.repeat(32);

    const app = createApp();
    const response = await app.request('/me');

    expect(response.status).toBe(401);
    await expect(response.json()).resolves.toEqual({ error: 'Unauthorized' });
  });
});
