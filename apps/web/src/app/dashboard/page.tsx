import Link from 'next/link';
import { UserButton } from '@clerk/nextjs';
import { auth, currentUser } from '@clerk/nextjs/server';
import { LogoMark } from '../../components/Logo';

export default async function DashboardPage() {
  await auth.protect();
  const user = await currentUser();
  const name =
    user?.firstName?.trim() ||
    user?.username?.trim() ||
    user?.primaryEmailAddress?.emailAddress?.split('@')[0] ||
    'sailor';

  return (
    <main className="dashboard">
      <div className="dashboard-backdrop" aria-hidden="true">
        <div className="dashboard-field" />
        <div className="dashboard-pattern" />
        <div className="dashboard-glow dashboard-glow-a" />
        <div className="dashboard-glow dashboard-glow-b" />
        <div className="dashboard-grain" />
      </div>

      <header className="dashboard-bar">
        <Link
          href="/dashboard"
          className="dashboard-brand-link"
          aria-label="Sailing Plans dashboard"
        >
          <LogoMark className="dashboard-bar-mark" title="Sailing Plans" />
          <span className="dashboard-bar-word">Sailing Plans</span>
        </Link>
        <UserButton
          appearance={{
            elements: {
              avatarBox: { width: '2.25rem', height: '2.25rem' },
            },
          }}
        />
      </header>

      <section className="dashboard-stage" aria-label="Dashboard home">
        <p className="dashboard-eyebrow">Dashboard</p>
        <h1 className="dashboard-brand">Sailing Plans</h1>
        <p className="dashboard-welcome">Welcome back, {name}.</p>
        <p className="dashboard-support">
          Your berth is reserved. Plans will appear here when we leave the dock.
        </p>

        <div className="dashboard-actions">
          <a
            className="cta"
            href="mailto:hello@sailingplans.com?subject=Early%20access"
          >
            Ask about early access
          </a>
          <Link className="cta cta-secondary" href="/">
            View the site
          </Link>
        </div>

        <p className="dashboard-status">
          <span className="dashboard-status-dot" aria-hidden="true" />
          Pre-launch · Account active
        </p>
      </section>
    </main>
  );
}
