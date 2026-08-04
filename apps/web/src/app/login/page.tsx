import Link from 'next/link';
import { SignIn } from '@clerk/nextjs';
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

        <div className="hero-copy hero-copy-auth">
          <div className="hero-brand-row">
            <LogoMark className="hero-mark" title="Sailing Plans" />
            <p className="eyebrow">Log in</p>
          </div>
          <div className="clerk-frame">
            <SignIn
              routing="hash"
              fallbackRedirectUrl="/"
              signUpUrl="/login"
              appearance={{
                variables: {
                  colorPrimary: '#71e5f2',
                  colorBackground: '#0c1f1e',
                  borderRadius: '2px',
                },
              }}
            />
          </div>
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
