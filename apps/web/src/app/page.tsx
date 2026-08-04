import { Atmosphere } from '../components/Atmosphere';
import { AuthCta } from '../components/AuthCta';
import { LogoMark } from '../components/Logo';
import { SiteFooter } from '../components/SiteFooter';

export default function HomePage() {
  return (
    <main className="shell shell-scroll">
      <section className="hero" aria-label="Sailing Plans">
        <Atmosphere variant="marketing" />

        <div className="hero-copy">
          <div className="hero-brand-row">
            <LogoMark className="hero-mark" title="Sailing Plans" />
          </div>
          <h1 className="brand">Sailing Plans</h1>
          <p className="eyebrow hero-eyebrow">Coming soon</p>
          <p className="headline">Plans that hold when the day gets loud.</p>
          <p className="support">
            A quiet place to capture what matters, choose the next step, and
            find your way back—without the noise.
          </p>
          <div className="cta-row">
            <AuthCta />
          </div>
          <p className="hero-waitlist">
            Prefer email?{' '}
            <a href="mailto:hello@sailingplans.com?subject=Waitlist">
              Join the waitlist
            </a>
          </p>
        </div>
      </section>

      <SiteFooter />
    </main>
  );
}
