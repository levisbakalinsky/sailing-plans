import Link from 'next/link';
import { COMPANY_NAME } from '../lib/company';
import { LogoMark } from './Logo';

const YEAR = new Date().getFullYear();

const LEGAL_LINKS = [
  { href: '/privacy', label: 'Privacy' },
  { href: '/terms', label: 'Terms' },
  { href: '/cookies', label: 'Cookies' },
] as const;

/** Site footer — legal links and copyright only (no auth, no mailing address). */
export function SiteFooter() {
  return (
    <footer className="site-footer-band" aria-label="Site">
      <div className="site-footer-inner">
        <div className="site-footer-columns site-footer-columns-legal">
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
