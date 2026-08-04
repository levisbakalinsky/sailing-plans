'use client';

import { Show, SignInButton, UserButton } from '@clerk/nextjs';

/** Secondary auth control for the landing CTA row. */
export function AuthCta() {
  return (
    <>
      <Show when="signed-out">
        <SignInButton mode="redirect" forceRedirectUrl="/">
          <button type="button" className="cta cta-secondary">
            Log in
          </button>
        </SignInButton>
      </Show>
      <Show when="signed-in">
        <span className="auth-user">
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
