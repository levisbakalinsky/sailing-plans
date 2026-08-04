import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import { ClerkProvider } from '@clerk/nextjs';
import { EB_Garamond, IBM_Plex_Mono, Source_Sans_3 } from 'next/font/google';
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

const mono = IBM_Plex_Mono({
  subsets: ['latin'],
  weight: ['400', '500'],
  variable: '--font-mono',
});

export const metadata: Metadata = {
  title: 'Sailing Plans',
  description: 'Plans that hold when the day gets loud.',
  icons: {
    icon: [{ url: '/brand/mark.svg', type: 'image/svg+xml' }],
    apple: [{ url: '/brand/mark.svg' }],
  },
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html
      lang="en"
      className={`${display.variable} ${body.variable} ${mono.variable}`}
    >
      <body>
        <ClerkProvider appearance={clerkAppearance} afterSignOutUrl="/">
          {children}
        </ClerkProvider>
      </body>
    </html>
  );
}
