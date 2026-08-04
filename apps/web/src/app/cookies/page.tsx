import type { Metadata } from 'next';
import Link from 'next/link';
import { LegalPage } from '../../components/LegalPage';
import {
  COMPANY_NAME,
  MAILING_ADDRESS_LINES,
  PRIVACY_EMAIL,
} from '../../lib/company';

export const metadata: Metadata = {
  title: 'Cookie Notice · Sailing Plans',
  description:
    'How Sailing Plans uses cookies and similar technologies, including Clerk authentication cookies.',
};

const UPDATED = 'August 4, 2026';
const CONTACT = PRIVACY_EMAIL;

export default function CookiesPage() {
  return (
    <LegalPage title="Cookie Notice" updated={UPDATED}>
      <p>
        This Cookie Notice explains how <strong>Avena Services, LLC</strong>{' '}
        (“Avena,” “we,” “us,” or “our”) uses cookies and similar technologies
        on <strong>Sailing Plans</strong> at{' '}
        <a href="https://www.sailingplans.com">www.sailingplans.com</a>. It
        should be read with our <Link href="/privacy">Privacy Policy</Link>.
      </p>

      <h2>1. What are cookies?</h2>
      <p>
        Cookies are small text files stored on your device when you visit a
        website. Similar technologies include local storage and session storage
        used by browsers or authentication libraries. They help sites remember
        preferences, keep you signed in, and understand basic technical
        behavior.
      </p>

      <h2>2. How we use cookies</h2>
      <p>
        Today, Sailing Plans uses cookies primarily for{' '}
        <strong>authentication and security</strong> through our identity
        provider, <strong>Clerk</strong>. These cookies are needed to:
      </p>
      <ul>
        <li>Keep you signed in across pages and sessions</li>
        <li>Protect accounts against unauthorized access and abuse</li>
        <li>Complete sign-in, sign-up, and sign-out flows reliably</li>
      </ul>
      <p>
        We do not currently set third-party advertising cookies or product
        analytics cookies on the marketing site. Infrastructure providers such
        as Cloudflare may process technical requests at the network edge as
        part of delivering and securing the site; that processing is described
        further in the Privacy Policy.
      </p>

      <h2>3. Categories we use</h2>
      <ul>
        <li>
          <strong>Strictly necessary</strong> — required for sign-in, session
          continuity, and security. The Service cannot offer authenticated
          features without these.
        </li>
        <li>
          <strong>Functional (if introduced later)</strong> — optional
          preferences such as UI settings. We will update this notice before
          relying on non-essential cookies of that kind.
        </li>
        <li>
          <strong>Analytics or advertising</strong> — not used on the site at
          this time. If we add them, we will update this notice and, where
          required, obtain consent.
        </li>
      </ul>

      <h2>4. Managing cookies</h2>
      <p>
        Most browsers let you block or delete cookies through their settings.
        If you block strictly necessary authentication cookies, you may not be
        able to sign in or use account features. Browser controls vary; check
        your browser’s help documentation for details.
      </p>
      <p>
        Where consent is required for non-essential cookies under GDPR or
        similar laws, we will not set those cookies until consent is obtained
        (and we will update this notice when such cookies are introduced).
      </p>

      <h2>5. Retention</h2>
      <p>
        Session cookies typically expire when you close your browser or after a
        short period defined by the authentication provider. Persistent cookies
        (if any) remain until they expire or you delete them. Clerk’s session
        lifetimes follow its configuration for our application.
      </p>

      <h2>6. More information</h2>
      <p>
        For broader information about personal data, rights, and processors,
        see the <Link href="/privacy">Privacy Policy</Link> and{' '}
        <Link href="/terms">Terms of Service</Link>. Questions:{' '}
        <a href={`mailto:${CONTACT}?subject=Cookie%20notice`}>{CONTACT}</a>.
      </p>
      <p>
        {COMPANY_NAME}
        <br />
        {MAILING_ADDRESS_LINES.map((line) => (
          <span key={line}>
            {line}
            <br />
          </span>
        ))}
      </p>
    </LegalPage>
  );
}
