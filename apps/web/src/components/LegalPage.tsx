import type { ReactNode } from 'react';
import { SiteFooter } from './SiteFooter';
import { SiteHeader } from './SiteHeader';

type LegalPageProps = {
  title: string;
  updated: string;
  children: ReactNode;
};

/** Shared chrome + typography for Privacy, Terms, and Cookies. */
export function LegalPage({ title, updated, children }: LegalPageProps) {
  return (
    <main className="shell shell-scroll">
      <SiteHeader />
      <article className="legal-page">
        <header className="legal-header">
          <p className="legal-kicker">Legal</p>
          <h1 className="legal-title">{title}</h1>
          <p className="legal-updated">Last updated: {updated}</p>
        </header>
        <div className="legal-body">{children}</div>
      </article>
      <SiteFooter />
    </main>
  );
}
