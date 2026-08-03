import { LogoMark } from '../components/Logo';

export default function HomePage() {
  return (
    <main className="shell">
      <section className="hero" aria-label="Sailing Plans">
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
            <p className="eyebrow">Coming soon</p>
          </div>
          <h1 className="brand">Sailing Plans</h1>
          <p className="headline">Plans that hold when the day gets loud.</p>
          <p className="support">
            A quiet place to capture what matters, choose the next step, and
            find your way back, without the noise.
          </p>
          <div className="cta-row">
            <a
              className="cta"
              href="mailto:hello@sailingplans.com?subject=Waitlist"
            >
              Join the waitlist
            </a>
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
