'use client';

import Link from 'next/link';
import { Show, SignInButton, SignUpButton } from '@clerk/nextjs';
import { LogoMark } from './Logo';

const YEAR = new Date().getFullYear();

/** DigitalOcean-style marketing footer — real links only; honest pre-launch placeholders. */
export function SiteFooter() {
  return (
    <footer className="site-footer-band" aria-label="Site">
      <div className="site-footer-inner">
        <div className="site-footer-top">
          <Link href="/" className="site-footer-brand" aria-label="Sailing Plans home">
            <LogoMark className="site-footer-brand-mark" title="Sailing Plans" />
            <span className="site-footer-brand-word">Sailing Plans</span>
          </Link>

          <nav className="site-footer-nav" aria-label="Footer">
            <a href="#product">Product</a>
            <a href="#company">Company</a>
            <a href="#legal">Legal</a>
          </nav>

          <div className="site-footer-auth">
            <Show when="signed-out">
              <SignInButton mode="redirect" forceRedirectUrl="/dashboard">
                <button type="button" className="site-footer-login">
                  Log in
                </button>
              </SignInButton>
              <SignUpButton mode="redirect" forceRedirectUrl="/dashboard">
                <button type="button" className="site-footer-signup">
                  Sign up
                </button>
              </SignUpButton>
            </Show>
            <Show when="signed-in">
              <Link className="site-footer-signup" href="/dashboard">
                Dashboard
              </Link>
            </Show>
          </div>
        </div>

        <div className="site-footer-columns">
          <div className="site-footer-col" id="product">
            <h2 className="site-footer-heading">Product</h2>
            <ul className="site-footer-list">
              <li>
                <Link href="/sign-up">Sign up</Link>
              </li>
              <li>
                <Link href="/login">Log in</Link>
              </li>
              <li>
                <Link href="/dashboard">Dashboard</Link>
              </li>
              <li>
                <span className="site-footer-soon">Plans — coming soon</span>
              </li>
            </ul>
          </div>

          <div className="site-footer-col" id="company">
            <h2 className="site-footer-heading">Company</h2>
            <ul className="site-footer-list">
              <li>
                <span className="site-footer-muted">Avena Services, LLC</span>
              </li>
              <li>
                <a href="mailto:hello@sailingplans.com">Contact</a>
              </li>
              <li>
                <a href="mailto:hello@sailingplans.com?subject=Waitlist">
                  Waitlist
                </a>
              </li>
            </ul>
          </div>

          <div className="site-footer-col" id="legal">
            <h2 className="site-footer-heading">Legal</h2>
            <ul className="site-footer-list">
              <li>
                <span className="site-footer-soon">Privacy — coming soon</span>
              </li>
              <li>
                <span className="site-footer-soon">Security — coming soon</span>
              </li>
              <li>
                <span className="site-footer-soon">Terms — coming soon</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="site-footer-bottom">
          <div className="site-footer-copy">
            <LogoMark className="site-footer-copy-mark" />
            <span>© {YEAR} Avena Services, LLC</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
