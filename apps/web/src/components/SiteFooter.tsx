import Link from 'next/link';
import {
  COMPANY_NAME,
  MAILING_ADDRESS_LINES,
  SALES_EMAIL,
} from '../lib/company';
import { LogoMark } from './Logo';

const YEAR = new Date().getFullYear();

const LEGAL_LINKS = [
  { href: '/privacy', label: 'Privacy' },
  { href: '/terms', label: 'Terms' },
  { href: '/cookies', label: 'Cookies' },
] as const;

/** DigitalOcean-style marketing footer — columns + legal, no auth chrome. */
export function SiteFooter() {
  return (
    <footer className="site-footer-band" aria-label="Site">
      <div className="site-footer-inner">
        <div className="site-footer-columns">
          <div className="site-footer-col">
            <h2 className="site-footer-heading">Product</h2>
            <ul className="site-footer-list">
              <li>
                <span className="site-footer-soon">Plans — coming soon</span>
              </li>
            </ul>
          </div>

          <div className="site-footer-col">
            <h2 className="site-footer-heading">Company</h2>
            <ul className="site-footer-list">
              <li>
                <span className="site-footer-muted">{COMPANY_NAME}</span>
              </li>
              <li>
                <address className="site-footer-address">
                  {MAILING_ADDRESS_LINES.map((line) => (
                    <span key={line}>{line}</span>
                  ))}
                </address>
              </li>
              <li>
                <a href={`mailto:${SALES_EMAIL}`}>Contact</a>
              </li>
              <li>
                <a href={`mailto:${SALES_EMAIL}?subject=Waitlist`}>
                  Waitlist
                </a>
              </li>
            </ul>
          </div>

          <div className="site-footer-col">
            <h2 className="site-footer-heading">Legal</h2>
            <ul className="site-footer-list">
              {LEGAL_LINKS.map((item) => (
                <li key={item.href}>
                  <Link href={item.href}>{item.label}</Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="site-footer-bottom">
          <div className="site-footer-copy">
            <LogoMark className="site-footer-copy-mark" />
            <span>
              © {YEAR} {COMPANY_NAME}
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
}
