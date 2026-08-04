import Link from 'next/link';
import type { ReactNode } from 'react';
import { LogoMark } from './Logo';

type AuthShellProps = {
  eyebrow: string;
  children: ReactNode;
};

/** Shared branded chrome for Clerk sign-in / sign-up pages. */
export function AuthShell({ eyebrow, children }: AuthShellProps) {
  return (
    <main className="shell">
      <section className="hero" aria-label={eyebrow}>
        <div className="hero-media" aria-hidden="true">
          <div className="hero-wash" />
          <div className="hero-glow hero-glow-a" />
          <div className="hero-glow hero-glow-b" />
          <div className="hero-horizon" />
          <div className="hero-grain" />
        </div>

        <div className="hero-copy hero-copy-auth">
          <div className="hero-brand-row">
            <LogoMark className="hero-mark" title="Sailing Plans" />
            <p className="eyebrow">{eyebrow}</p>
          </div>
          <div className="clerk-frame">{children}</div>
          <p className="auth-back">
            <Link href="/">Back home</Link>
          </p>
        </div>

        <footer className="site-footer">
          <span className="footer-meta">
            © {new Date().getFullYear()} Avena Services, LLC
          </span>
          <a className="footer-mail" href="mailto:hello@sailingplans.com">
            hello@sailingplans.com
          </a>
        </footer>
      </section>
    </main>
  );
}
