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
