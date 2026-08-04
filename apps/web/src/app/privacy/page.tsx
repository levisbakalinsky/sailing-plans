import type { Metadata } from 'next';
import Link from 'next/link';
import { LegalPage } from '../../components/LegalPage';
import {
  COMPANY_NAME,
  MAILING_ADDRESS_LINES,
  PRIVACY_EMAIL,
} from '../../lib/company';

export const metadata: Metadata = {
  title: 'Privacy Policy · Sailing Plans',
  description:
    'How Avena Services, LLC collects, uses, and protects personal information for Sailing Plans.',
};

const UPDATED = 'August 4, 2026';
const CONTACT = PRIVACY_EMAIL;

export default function PrivacyPage() {
  return (
    <LegalPage title="Privacy Policy" updated={UPDATED}>
      <p>
        This Privacy Policy explains how <strong>Avena Services, LLC</strong>{' '}
        (“Avena,” “we,” “us,” or “our”) collects, uses, discloses, and protects
        personal information when you use <strong>Sailing Plans</strong> at{' '}
        <a href="https://www.sailingplans.com">www.sailingplans.com</a> and
        related services (the “Service”).
      </p>
      <p>
        We designed this policy to address requirements and expectations under
        the EU General Data Protection Regulation (GDPR), Canadian privacy law
        (including PIPEDA and, where applicable, Québec Law 25), and the
        California Consumer Privacy Act as amended by the CPRA (CCPA/CPRA).
      </p>

      <h2>1. Who is responsible</h2>
      <p>
        The data controller (and organization accountable for personal
        information) is:
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
        Product: Sailing Plans
        <br />
        Email:{' '}
        <a href={`mailto:${CONTACT}?subject=Privacy%20request`}>{CONTACT}</a>
      </p>
      <p>
        Privacy and data-subject requests should go to the same address with a
        clear subject line (for example, “Privacy request”).
      </p>

      <h2>2. Information we collect</h2>
      <p>Depending on how you use the Service, we may process:</p>
      <ul>
        <li>
          <strong>Account and identity data</strong> — name, email address,
          username, profile details, and authentication identifiers when you
          create or sign in to an account. Sign-in is provided by an
          authentication provider; we receive account data needed to operate
          signed-in features.
        </li>
        <li>
          <strong>Communications</strong> — messages you send us, including
          waitlist or contact emails to {CONTACT}.
        </li>
        <li>
          <strong>Usage and technical data</strong> — IP address, device and
          browser type, approximate location derived from IP, pages or routes
          requested, timestamps, and diagnostic or server logs generated while
          providing and securing the Service.
        </li>
        <li>
          <strong>Cookies and similar technologies</strong> — session and
          authentication cookies required for sign-in and account security. See
          our <Link href="/cookies">Cookie Notice</Link>.
        </li>
      </ul>
      <p>
        We do not currently operate a third-party advertising or product
        analytics pixel on the marketing site. If we add analytics or similar
        tools later, we will update this policy and the Cookie Notice.
      </p>

      <h2>3. How we use information (purposes)</h2>
      <ul>
        <li>Provide, maintain, and secure accounts and the Service</li>
        <li>Authenticate users and prevent abuse or fraud</li>
        <li>Respond to waitlist, support, and privacy requests</li>
        <li>Operate hosting, delivery, and infrastructure for availability</li>
        <li>Comply with law and enforce our Terms of Service</li>
        <li>Improve the Service based on operational needs and feedback</li>
      </ul>

      <h2>4. Legal bases (GDPR / similar regimes)</h2>
      <p>Where GDPR or analogous rules apply, we rely on:</p>
      <ul>
        <li>
          <strong>Contract</strong> — processing needed to provide the Service
          you request (for example, account creation and sign-in).
        </li>
        <li>
          <strong>Legitimate interests</strong> — securing the Service,
          preventing abuse, basic operations and logging, in ways that do not
          override your rights.
        </li>
        <li>
          <strong>Consent</strong> — where we ask for it (for example, optional
          marketing email if we offer it), which you may withdraw at any time.
        </li>
        <li>
          <strong>Legal obligation</strong> — when we must retain or disclose
          information to meet applicable law.
        </li>
      </ul>

      <h2>5. Canada (PIPEDA / Law 25 awareness)</h2>
      <p>
        We are accountable for personal information under our control. We
        collect, use, and disclose personal information for the purposes
        described in this policy, and we seek meaningful consent where required
        (for example, when you submit a waitlist email or create an account).
        You may request access to, or correction of, your personal information
        by contacting us at {CONTACT}. We will respond within the timeframes
        required by applicable Canadian law. If you are in Québec, additional
        Law 25 rights and transparency expectations may apply; contact us to
        exercise them.
      </p>

      <h2>6. California (CCPA/CPRA)</h2>
      <p>
        In the prior 12 months, depending on your use of the Service, we may
        have collected the following categories of personal information:
        identifiers (such as name, email, IP address, account ID); internet or
        other electronic network activity (such as logs and interactions with
        the Service); and, if you provide them, limited profile or contact
        details.
      </p>
      <p>
        We use these categories for the business purposes listed in Section 3
        (providing the Service, security, customer communication, and
        compliance).
      </p>
      <p>
        <strong>We do not sell personal information</strong> and we do not
        “share” personal information for cross-context behavioral advertising as
        those terms are defined under the CCPA/CPRA. Because we do not sell or
        share in that sense, we do not currently offer a “Do Not Sell or Share
        My Personal Information” opt-out mechanism beyond the rights below. If
        that changes, we will update this policy and provide a clear method to
        opt out.
      </p>
      <p>California residents may have the right to:</p>
      <ul>
        <li>Know what personal information we collect and how it is used</li>
        <li>Delete personal information, subject to legal exceptions</li>
        <li>Correct inaccurate personal information</li>
        <li>Opt out of sale or sharing (if applicable in the future)</li>
        <li>Not be discriminated against for exercising privacy rights</li>
      </ul>
      <p>
        To exercise these rights, email{' '}
        <a href={`mailto:${CONTACT}?subject=California%20privacy%20request`}>
          {CONTACT}
        </a>
        . We may need to verify your identity before fulfilling a request. You
        may use an authorized agent where the law allows; we may require proof
        of authorization.
      </p>

      <h2>7. Processors and service providers</h2>
      <p>
        We use trusted service providers to help run the Service. They process
        personal information on our instructions and for our purposes,
        including categories such as:
      </p>
      <ul>
        <li>
          <strong>Authentication providers</strong> — sign-in, session
          management, and account identity services
        </li>
        <li>
          <strong>Hosting providers</strong> — application hosting and managed
          data storage
        </li>
        <li>
          <strong>Content delivery and security providers</strong> — DNS, CDN,
          and edge security for the website
        </li>
        <li>
          <strong>Email services</strong> — delivering transactional or
          waitlist-related messages when you contact us
        </li>
      </ul>
      <p>
        These providers may process data in the United States or other
        countries where they operate.
      </p>

      <h2>8. International transfers</h2>
      <p>
        If you access the Service from the EEA, UK, Switzerland, Canada, or
        elsewhere, your information may be transferred to and processed in the
        United States and other countries that may have different data
        protection laws. Where required, we rely on appropriate safeguards
        offered by our providers (such as Standard Contractual Clauses) and
        contractual commitments with processors.
      </p>

      <h2>9. Retention</h2>
      <p>
        We keep personal information only as long as needed for the purposes
        above: while your account is active; for a reasonable period afterward
        for security, dispute resolution, and legal compliance; and for
        communications you send us according to ordinary business retention
        practices. Server logs are typically retained for a shorter operational
        window unless needed for security investigations. You may request
        deletion as described below.
      </p>

      <h2>10. Your rights (GDPR and similar)</h2>
      <p>Subject to applicable law, you may have the right to:</p>
      <ul>
        <li>Access the personal data we hold about you</li>
        <li>Rectify inaccurate data</li>
        <li>Erase data (“right to be forgotten”)</li>
        <li>Restrict or object to certain processing</li>
        <li>Receive a portable copy of data you provided</li>
        <li>Withdraw consent where processing is consent-based</li>
        <li>
          Lodge a complaint with a supervisory authority in your country or
          region
        </li>
      </ul>
      <p>
        To exercise these rights, contact{' '}
        <a href={`mailto:${CONTACT}?subject=Privacy%20request`}>{CONTACT}</a>.
        We will respond within the period required by applicable law.
      </p>

      <h2>11. Security</h2>
      <p>
        We use reasonable administrative, technical, and organizational
        measures appropriate to the nature of the Service (including encrypted
        transport, access controls, and authenticated APIs). No method of
        transmission or storage is perfectly secure. If we become aware of a
        breach that requires notification under applicable law (including
        Canadian breach reporting rules where they apply), we will notify
        affected individuals and authorities as required.
      </p>

      <h2>12. Children</h2>
      <p>
        The Service is not directed to children under 16 (or the minimum age
        required in your jurisdiction). We do not knowingly collect personal
        information from children. If you believe a child has provided us
        information, contact us and we will take appropriate steps.
      </p>

      <h2>13. Changes</h2>
      <p>
        We may update this Privacy Policy from time to time. The “Last updated”
        date at the top will change when we do. Material changes will be posted
        on this page; continued use of the Service after an update means you
        acknowledge the revised policy.
      </p>

      <h2>14. Contact</h2>
      <p>
        Questions or privacy requests:{' '}
        <a href={`mailto:${CONTACT}`}>{CONTACT}</a>
        <br />
        {COMPANY_NAME} — Sailing Plans
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
