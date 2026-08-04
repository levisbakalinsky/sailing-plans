import { Atmosphere } from '../components/Atmosphere';
import { AuthCta } from '../components/AuthCta';
import { LogoMark } from '../components/Logo';
import { SiteFooter } from '../components/SiteFooter';
import { SiteHeader } from '../components/SiteHeader';
import { SALES_EMAIL } from '../lib/company';

export default function HomePage() {
  return (
    <main className="shell shell-scroll">
      <SiteHeader />
      <section className="hero" aria-label="Sailing Plans">
        <Atmosphere variant="marketing" />

        <div className="hero-copy">
          <div className="hero-brand-row">
            <LogoMark className="hero-mark" title="Sailing Plans" />
          </div>
          <h1 className="brand">Sailing Plans</h1>
          <p className="eyebrow hero-eyebrow">Coming soon</p>
          <div className="cta-row">
            <AuthCta />
          </div>
          <p className="hero-waitlist">
            Prefer email?{' '}
            <a href={`mailto:${SALES_EMAIL}?subject=Waitlist`}>
              Join the waitlist
            </a>
          </p>
        </div>
      </section>

      <SiteFooter />
    </main>
  );
}
