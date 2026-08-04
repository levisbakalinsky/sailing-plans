import Link from 'next/link';
import { UserButton } from '@clerk/nextjs';
import { auth, currentUser } from '@clerk/nextjs/server';
import { LogoMark } from '../../components/Logo';

export default async function PortalPage() {
  await auth.protect();
  const user = await currentUser();
  const name =
    user?.firstName?.trim() ||
    user?.username?.trim() ||
    user?.primaryEmailAddress?.emailAddress?.split('@')[0] ||
    'sailor';

  return (
    <main className="portal">
      <div className="portal-backdrop" aria-hidden="true">
        <div className="portal-field" />
        <div className="portal-pattern" />
        <div className="portal-glow portal-glow-a" />
        <div className="portal-glow portal-glow-b" />
        <div className="portal-grain" />
      </div>

      <header className="portal-bar">
        <Link href="/portal" className="portal-brand-link" aria-label="Sailing Plans portal">
          <LogoMark className="portal-bar-mark" title="Sailing Plans" />
          <span className="portal-bar-word">Sailing Plans</span>
        </Link>
        <UserButton
          appearance={{
            elements: {
              avatarBox: { width: '2.25rem', height: '2.25rem' },
            },
          }}
        />
      </header>

      <section className="portal-stage" aria-label="Portal home">
        <p className="portal-eyebrow">Portal</p>
        <h1 className="portal-brand">Sailing Plans</h1>
        <p className="portal-welcome">Welcome back, {name}.</p>
        <p className="portal-support">
          Your berth is reserved. Plans will appear here when we leave the dock.
        </p>

        <div className="portal-actions">
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

        <p className="portal-status">
          <span className="portal-status-dot" aria-hidden="true" />
          Pre-launch · Account active
        </p>
      </section>
    </main>
  );
}
