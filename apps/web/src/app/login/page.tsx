import Link from 'next/link';
import { LogoMark } from '../../components/Logo';

export default function LoginPage() {
  return (
    <main className="shell">
      <section className="hero" aria-label="Log in">
        <div className="hero-media" aria-hidden="true">
          <div className="hero-wash" />
          <div className="hero-glow hero-glow-a" />
          <div className="hero-glow hero-glow-b" />
          <div className="hero-horizon" />
          <div className="hero-grain" />
        </div>

        <div className="hero-copy">
          <div className="hero-brand-row">
            <LogoMark className="hero-mark" title="Sailing Plans" />
            <p className="eyebrow">Log in</p>
          </div>
          <h1 className="brand brand-compact">Not open yet</h1>
          <p className="headline">
            Sign-in will be here when we launch. Join the waitlist for first
            word.
          </p>
          <div className="cta-row">
            <a
              className="cta"
              href="mailto:hello@sailingplans.com?subject=Waitlist"
            >
              Join the waitlist
            </a>
            <Link className="cta cta-secondary" href="/">
              Back home
            </Link>
          </div>
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
