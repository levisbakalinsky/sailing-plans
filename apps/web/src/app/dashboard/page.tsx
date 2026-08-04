import Link from 'next/link';
import { UserButton } from '@clerk/nextjs';
import { auth, currentUser } from '@clerk/nextjs/server';
import { Atmosphere } from '../../components/Atmosphere';
import { LogoMark } from '../../components/Logo';
import { clerkUserButtonAppearance } from '../../lib/clerkAppearance';

function NavIconHome() {
  return (
    <svg viewBox="0 0 20 20" width="18" height="18" aria-hidden="true">
      <path
        d="M3.5 8.5 10 3l6.5 5.5V16a1 1 0 0 1-1 1h-3.5v-4.5H8V17H4.5a1 1 0 0 1-1-1V8.5Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.4"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function NavIconPlans() {
  return (
    <svg viewBox="0 0 20 20" width="18" height="18" aria-hidden="true">
      <path
        d="M4 5.5h12M4 10h12M4 14.5h8"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.4"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default async function DashboardPage() {
  await auth.protect();
  const user = await currentUser();
  const name =
    user?.firstName?.trim() ||
    user?.username?.trim() ||
    user?.primaryEmailAddress?.emailAddress?.split('@')[0] ||
    'sailor';

  return (
    <div className="dashboard">
      <aside className="dashboard-sidebar" aria-label="Dashboard navigation">
        <Link href="/dashboard" className="dashboard-side-brand">
          <LogoMark className="dashboard-side-mark" title="Sailing Plans" />
          <span className="dashboard-side-word">Sailing Plans</span>
        </Link>

        <nav className="dashboard-nav">
          <p className="dashboard-nav-label">Manage</p>
          <Link href="/dashboard" className="dashboard-nav-item is-active">
            <NavIconHome />
            <span className="dashboard-nav-text">Home</span>
          </Link>
          <span className="dashboard-nav-item is-disabled" aria-disabled="true">
            <NavIconPlans />
            <span className="dashboard-nav-text">Plans</span>
            <span className="dashboard-nav-soon">Soon</span>
          </span>
        </nav>
      </aside>

      <div className="dashboard-main">
        <header className="dashboard-topbar">
          <div className="dashboard-search" aria-hidden="true">
            <span className="dashboard-search-text">Search plans…</span>
            <span className="dashboard-search-hint">⌘K</span>
          </div>
          <div className="dashboard-top-actions">
            <span className="dashboard-create is-disabled" aria-disabled="true">
              Create
            </span>
            <UserButton appearance={clerkUserButtonAppearance} />
          </div>
        </header>

        <section className="dashboard-canvas" aria-label="Dashboard home">
          <Atmosphere variant="dashboard" />
          <div className="dashboard-stage">
            <p className="dashboard-eyebrow">Welcome aboard</p>
            <h1 className="dashboard-brand">Sailing Plans</h1>
            <p className="dashboard-welcome">Good to see you, {name}.</p>
            <p className="dashboard-support">
              Your berth is reserved. Plans will appear here when we leave the
              dock.
            </p>
            <div className="dashboard-actions">
              <span className="dashboard-cta">Plans coming soon</span>
              <Link className="dashboard-cta dashboard-cta-ghost" href="/">
                View the site
              </Link>
            </div>
            <p className="dashboard-status">
              <span className="dashboard-status-dot" aria-hidden="true" />
              Pre-launch · Account active
            </p>
          </div>
        </section>
      </div>
    </div>
  );
}
