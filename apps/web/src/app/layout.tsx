import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import { ClerkProvider } from '@clerk/nextjs';
import { EB_Garamond, Source_Sans_3 } from 'next/font/google';
import { clerkAppearance } from '../lib/clerkAppearance';
import './globals.css';

const display = EB_Garamond({
  subsets: ['latin'],
  variable: '--font-display',
});

const body = Source_Sans_3({
  subsets: ['latin'],
  variable: '--font-body',
});

export const metadata: Metadata = {
  title: 'Sailing Plans',
  description: 'Plans that hold when the day gets loud.',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable}`}>
      <body>
        <ClerkProvider appearance={clerkAppearance} afterSignOutUrl="/">
          {children}
        </ClerkProvider>
      </body>
    </html>
  );
}
