import type { Metadata } from 'next';
import Link from 'next/link';
import { LegalPage } from '../../components/LegalPage';

export const metadata: Metadata = {
  title: 'Terms of Service · Sailing Plans',
  description:
    'Terms of Service for Sailing Plans, operated by Avena Services, LLC.',
};

const UPDATED = 'August 4, 2026';
const CONTACT = 'hello@sailingplans.com';

export default function TermsPage() {
  return (
    <LegalPage title="Terms of Service" updated={UPDATED}>
      <p>
        These Terms of Service (“Terms”) govern access to and use of{' '}
        <strong>Sailing Plans</strong> at{' '}
        <a href="https://www.sailingplans.com">www.sailingplans.com</a> and
        related services (the “Service”) provided by{' '}
        <strong>Avena Services, LLC</strong> (“Avena,” “we,” “us,” or “our”).
        By using the Service, you agree to these Terms. If you do not agree, do
        not use the Service.
      </p>

      <h2>1. The Service</h2>
      <p>
        Sailing Plans is a planning product offered by Avena. Features may be
        pre-launch, limited, or change over time. We may add, modify, or
        discontinue functionality with or without notice, including during
        early access or waitlist periods.
      </p>

      <h2>2. Eligibility and accounts</h2>
      <p>
        You must be able to form a binding contract under applicable law to use
        the Service. You are responsible for the accuracy of information you
        provide and for keeping your login credentials secure. Account
        authentication is handled by Clerk; activity under your account is your
        responsibility unless you notify us of unauthorized access.
      </p>
      <p>
        We may suspend or terminate accounts that violate these Terms, create
        risk to the Service or other users, or are inactive for an extended
        period.
      </p>

      <h2>3. Acceptable use</h2>
      <p>You agree not to:</p>
      <ul>
        <li>Use the Service for unlawful, harmful, or fraudulent purposes</li>
        <li>
          Attempt to gain unauthorized access to systems, accounts, or data
        </li>
        <li>
          Interfere with or disrupt the Service, including by malware, abuse of
          APIs, or unreasonable load
        </li>
        <li>
          Reverse engineer or scrape the Service except where applicable law
          prohibits that restriction
        </li>
        <li>
          Misrepresent your identity or affiliation when communicating with us
        </li>
      </ul>

      <h2>4. Your content</h2>
      <p>
        You retain ownership of content you submit to the Service (“Your
        Content”). You grant Avena a limited license to host, process, and
        display Your Content solely as needed to operate and improve the
        Service. You represent that you have the rights needed to submit Your
        Content and that it does not violate law or third-party rights.
      </p>

      <h2>5. Waitlist and communications</h2>
      <p>
        If you join a waitlist or contact us at {CONTACT}, we may use your
        email to respond and to share product updates related to Sailing Plans.
        You can ask us to stop non-essential messages by emailing us. Our
        handling of personal information is described in the{' '}
        <Link href="/privacy">Privacy Policy</Link>.
      </p>

      <h2>6. Third-party services</h2>
      <p>
        The Service relies on third parties such as Clerk (authentication),
        DigitalOcean (hosting and databases), and Cloudflare (CDN and DNS).
        Their terms and privacy practices apply to their processing. We are not
        responsible for third-party services we do not control.
      </p>

      <h2>7. Intellectual property</h2>
      <p>
        The Service, including software, design, branding (including the Sail
        mark and “Sailing Plans” name), and documentation, is owned by Avena or
        its licensors. These Terms do not grant you any right to use our marks
        except as needed to use the Service itself.
      </p>

      <h2>8. Disclaimer of warranties</h2>
      <p>
        THE SERVICE IS PROVIDED “AS IS” AND “AS AVAILABLE.” TO THE MAXIMUM
        EXTENT PERMITTED BY LAW, AVENA DISCLAIMS ALL WARRANTIES, WHETHER
        EXPRESS, IMPLIED, OR STATUTORY, INCLUDING MERCHANTABILITY, FITNESS FOR
        A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE
        SERVICE WILL BE UNINTERRUPTED, ERROR-FREE, OR COMPLETELY SECURE.
      </p>

      <h2>9. Limitation of liability</h2>
      <p>
        TO THE MAXIMUM EXTENT PERMITTED BY LAW, AVENA AND ITS OFFICERS,
        DIRECTORS, EMPLOYEES, AND AGENTS WILL NOT BE LIABLE FOR INDIRECT,
        INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR FOR LOSS OF
        PROFITS, DATA, OR GOODWILL, ARISING FROM OR RELATED TO YOUR USE OF THE
        SERVICE. OUR TOTAL LIABILITY FOR ANY CLAIM RELATING TO THE SERVICE WILL
        NOT EXCEED THE GREATER OF (A) THE AMOUNTS YOU PAID US FOR THE SERVICE
        IN THE TWELVE MONTHS BEFORE THE CLAIM OR (B) ONE HUNDRED U.S. DOLLARS
        (US $100).
      </p>
      <p>
        Some jurisdictions do not allow certain limitations; in those places,
        our liability is limited to the fullest extent permitted by law.
      </p>

      <h2>10. Indemnity</h2>
      <p>
        You will defend and indemnify Avena against claims, damages, and
        expenses (including reasonable attorneys’ fees) arising from Your
        Content or your misuse of the Service or violation of these Terms,
        except to the extent caused by our willful misconduct.
      </p>

      <h2>11. Termination</h2>
      <p>
        You may stop using the Service at any time. We may suspend or end
        access if you breach these Terms or if we discontinue the Service. Upon
        termination, provisions that by their nature should survive (including
        ownership, disclaimers, limitations of liability, and governing law)
        will survive.
      </p>

      <h2>12. Governing law</h2>
      <p>
        These Terms are governed by the laws of the United States and the laws
        of the state in which Avena Services, LLC is organized, without regard
        to conflict-of-law rules. Courts in that jurisdiction will have
        exclusive venue for disputes that are not resolved informally, except
        where applicable consumer protection law requires otherwise.
      </p>

      <h2>13. Changes to these Terms</h2>
      <p>
        We may update these Terms from time to time. The “Last updated” date
        will change when we do. If changes are material, we will post the
        updated Terms on this page. Continued use of the Service after the
        effective date constitutes acceptance of the updated Terms.
      </p>

      <h2>14. Contact</h2>
      <p>
        Questions about these Terms:{' '}
        <a href={`mailto:${CONTACT}`}>{CONTACT}</a>
        <br />
        Avena Services, LLC — Sailing Plans
      </p>
    </LegalPage>
  );
}
