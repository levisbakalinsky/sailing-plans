'use client';

import Link from 'next/link';
import { useEffect, useId, useState } from 'react';
import {
  Show,
  SignInButton,
  SignUpButton,
  UserButton,
} from '@clerk/nextjs';
import { clerkUserButtonAppearance } from '../lib/clerkAppearance';
import { LogoMark } from './Logo';

const NAV = [
  { href: '#product', label: 'Product' },
  { href: '#company', label: 'Company' },
] as const;

/** DigitalOcean-style solid black marketing chrome — real destinations only. */
export function SiteHeader() {
  const [open, setOpen] = useState(false);
  const menuId = useId();

  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  return (
    <header className="site-header">
      <div className="site-header-inner">
        <Link href="/" className="site-header-brand" aria-label="Sailing Plans home">
          <LogoMark className="site-header-mark" title="Sailing Plans" />
          <span className="site-header-word">Sailing Plans</span>
        </Link>

        <nav className="site-header-nav" aria-label="Primary">
          {NAV.map((item) => (
            <a key={item.href} href={item.href}>
              {item.label}
            </a>
          ))}
        </nav>

        <div className="site-header-actions">
          <Show when="signed-out">
            <SignInButton mode="redirect" forceRedirectUrl="/dashboard">
              <button type="button" className="site-header-login">
                Log in
              </button>
            </SignInButton>
            <SignUpButton mode="redirect" forceRedirectUrl="/dashboard">
              <button type="button" className="site-header-signup">
                Sign up
              </button>
            </SignUpButton>
          </Show>
          <Show when="signed-in">
            <Link className="site-header-login" href="/dashboard">
              Dashboard
            </Link>
            <UserButton
              appearance={{
                ...clerkUserButtonAppearance,
                elements: {
                  ...clerkUserButtonAppearance.elements,
                  avatarBox: { width: '2rem', height: '2rem' },
                },
              }}
            />
          </Show>
        </div>

        <button
          type="button"
          className="site-header-menu"
          aria-expanded={open}
          aria-controls={menuId}
          aria-label={open ? 'Close menu' : 'Open menu'}
          onClick={() => setOpen((value) => !value)}
        >
          <span className={open ? 'is-open' : undefined} aria-hidden="true" />
        </button>
      </div>

      {open ? (
        <div className="site-header-drawer" id={menuId}>
          <nav className="site-header-drawer-nav" aria-label="Mobile">
            {NAV.map((item) => (
              <a
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
              >
                {item.label}
              </a>
            ))}
          </nav>
          <div className="site-header-drawer-actions">
            <Show when="signed-out">
              <SignInButton mode="redirect" forceRedirectUrl="/dashboard">
                <button
                  type="button"
                  className="site-header-login"
                  onClick={() => setOpen(false)}
                >
                  Log in
                </button>
              </SignInButton>
              <SignUpButton mode="redirect" forceRedirectUrl="/dashboard">
                <button
                  type="button"
                  className="site-header-signup"
                  onClick={() => setOpen(false)}
                >
                  Sign up
                </button>
              </SignUpButton>
            </Show>
            <Show when="signed-in">
              <Link
                className="site-header-signup"
                href="/dashboard"
                onClick={() => setOpen(false)}
              >
                Dashboard
              </Link>
            </Show>
          </div>
        </div>
      ) : null}
    </header>
  );
}
