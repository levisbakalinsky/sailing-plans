'use client';

import Link from 'next/link';
import {
  Show,
  SignInButton,
  SignUpButton,
  UserButton,
} from '@clerk/nextjs';
import { clerkUserButtonAppearance } from '../lib/clerkAppearance';

/** Auth controls for the marketing CTA row. */
export function AuthCta() {
  return (
    <>
      <Show when="signed-out">
        <SignUpButton mode="redirect" forceRedirectUrl="/dashboard">
          <button type="button" className="cta">
            Sign up
          </button>
        </SignUpButton>
        <SignInButton mode="redirect" forceRedirectUrl="/dashboard">
          <button type="button" className="cta cta-secondary">
            Log in
          </button>
        </SignInButton>
      </Show>
      <Show when="signed-in">
        <span className="auth-user auth-user-signed-in">
          <Link className="cta" href="/dashboard">
            Open dashboard
          </Link>
          <UserButton
            appearance={{
              ...clerkUserButtonAppearance,
              elements: {
                ...clerkUserButtonAppearance.elements,
                avatarBox: { width: '2.5rem', height: '2.5rem' },
              },
            }}
          />
        </span>
      </Show>
    </>
  );
}
