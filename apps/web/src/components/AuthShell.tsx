import Link from 'next/link';
import type { ReactNode } from 'react';
import { Atmosphere } from './Atmosphere';
import { LogoMark } from './Logo';

type AuthShellProps = {
  mode: 'login' | 'sign-up';
  children: ReactNode;
};

/** Shared branded chrome for all Clerk auth screens (sign-in, sign-up, reset). */
export function AuthShell({ mode, children }: AuthShellProps) {
  const switchLink =
    mode === 'login' ? (
      <p className="auth-switch">
        Don&apos;t have an account?{' '}
        <Link href="/sign-up">Sign up</Link>
      </p>
    ) : (
      <p className="auth-switch">
        Already have an account?{' '}
        <Link href="/login">Sign in</Link>
      </p>
    );

  return (
    <main className="auth-shell">
      <Atmosphere variant="auth" />

      <header className="auth-top">
        <Link href="/" className="auth-brand" aria-label="Sailing Plans home">
          <LogoMark className="auth-brand-mark" title="Sailing Plans" />
          <span className="auth-brand-word">Sailing Plans</span>
        </Link>
        {switchLink}
      </header>

      <div className="auth-stage">
        <div className="clerk-frame">{children}</div>
      </div>
    </main>
  );
}
