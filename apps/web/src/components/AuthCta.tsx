'use client';

import Link from 'next/link';
import { Show, SignInButton, UserButton } from '@clerk/nextjs';

/** Secondary auth control for the landing CTA row. */
export function AuthCta() {
  return (
    <>
      <Show when="signed-out">
        <SignInButton mode="redirect" forceRedirectUrl="/portal">
          <button type="button" className="cta cta-secondary">
            Log in
          </button>
        </SignInButton>
      </Show>
      <Show when="signed-in">
        <span className="auth-user auth-user-signed-in">
          <Link className="cta cta-secondary" href="/portal">
            Open portal
          </Link>
          <UserButton
            appearance={{
              elements: {
                avatarBox: { width: '2.5rem', height: '2.5rem' },
              },
            }}
          />
        </span>
      </Show>
    </>
  );
}
