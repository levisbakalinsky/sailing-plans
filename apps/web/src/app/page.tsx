async function getApiHealth() {
  // Prefer an in-network URL when running in Docker; fall back to the public API URL for local/dev.
  const baseUrl =
    process.env.API_INTERNAL_URL ??
    process.env.NEXT_PUBLIC_API_URL ??
    'http://localhost:3001';

  try {
    const response = await fetch(`${baseUrl}/health`, {
      cache: 'no-store',
    });

    if (!response.ok) {
      return { ok: false as const, message: `API responded ${response.status}` };
    }

    const body = (await response.json()) as {
      status: string;
      service: string;
      timestamp: string;
    };

    return { ok: true as const, body };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return { ok: false as const, message };
  }
}

export default async function HomePage() {
  const health = await getApiHealth();

  return (
    <main>
      <section className="panel">
        <h1 className="brand">Sailing Plans</h1>
        <p className="lede">Local web shell talking to the Hono API.</p>
        <p className="status">
          {health.ok
            ? `API ${health.body.status} · ${health.body.service} · ${health.body.timestamp}`
            : `API unreachable · ${health.message}`}
        </p>
      </section>
    </main>
  );
}
