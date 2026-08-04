/**
 * Light Clerk card on the dark auth shell — readable labels, inputs, and links.
 * Teal brand accent; large radius to match DO-style auth cards.
 */
export const clerkAppearance = {
  variables: {
    colorPrimary: '#0d8a96',
    colorDanger: '#b42318',
    colorSuccess: '#0f6b4c',
    colorWarning: '#9a6700',
    colorText: '#0b1220',
    colorTextSecondary: '#5b6578',
    colorBackground: '#ffffff',
    colorInputBackground: '#ffffff',
    colorInputText: '#0b1220',
    colorNeutral: '#0b1220',
    borderRadius: '12px',
    fontFamily: 'var(--font-body), "Source Sans 3", sans-serif',
    fontFamilyButtons: 'var(--font-body), "Source Sans 3", sans-serif',
  },
  elements: {
    rootBox: {
      width: '100%',
    },
    cardBox: {
      background: '#ffffff',
      boxShadow: '0 24px 64px rgba(0, 0, 0, 0.45)',
      border: '1px solid rgba(255, 255, 255, 0.92)',
      borderRadius: '20px',
    },
    card: {
      background: '#ffffff',
      boxShadow: 'none',
      borderRadius: '20px',
      padding: '1.75rem 1.75rem 1.25rem',
    },
    headerTitle: {
      color: '#0b1220',
      fontFamily: 'var(--font-body), "Source Sans 3", sans-serif',
      fontWeight: '700',
      fontSize: '1.65rem',
      letterSpacing: '-0.02em',
    },
    headerSubtitle: {
      color: '#5b6578',
      fontSize: '0.95rem',
    },
    formFieldLabel: {
      color: '#0d8a96',
      fontFamily: 'var(--font-mono), ui-monospace, monospace',
      fontSize: '0.78rem',
      fontWeight: '500',
      letterSpacing: '0.01em',
      textTransform: 'lowercase',
    },
    formFieldInput: {
      background: '#ffffff',
      color: '#0b1220',
      borderColor: 'rgba(11, 18, 32, 0.16)',
      borderRadius: '8px',
    },
    footer: {
      background: '#f7f9fb',
      borderBottomLeftRadius: '20px',
      borderBottomRightRadius: '20px',
    },
    footerActionText: {
      color: '#5b6578',
    },
    footerActionLink: {
      color: '#0d8a96',
      fontWeight: '600',
      textDecoration: 'underline',
      textUnderlineOffset: '3px',
    },
    identityPreviewText: {
      color: '#0b1220',
    },
    identityPreviewEditButton: {
      color: '#0d8a96',
    },
    formButtonPrimary: {
      background: '#18c4d4',
      color: '#001214',
      fontWeight: '700',
      borderRadius: '999px',
      '&:hover': {
        background: '#4dd5e0',
      },
    },
    socialButtonsBlockButton: {
      borderRadius: '10px',
      borderColor: 'rgba(11, 18, 32, 0.16)',
      background: '#ffffff',
    },
    formFieldAction: {
      color: '#0d8a96',
      textDecoration: 'underline',
      textUnderlineOffset: '3px',
    },
  },
} as const;

/**
 * Dark UserButton menu — console panel with readable white/grey text + teal accents.
 * Pair with `.cl-userButton*` CSS overrides so portal content doesn't inherit body ink.
 */
export const clerkUserButtonAppearance = {
  variables: {
    colorPrimary: '#18c4d4',
    colorText: '#f4f5f5',
    colorTextSecondary: '#a8aebc',
    colorBackground: '#12141c',
    colorNeutral: '#f4f5f5',
    colorInputBackground: '#1a1d27',
    colorInputText: '#f4f5f5',
    borderRadius: '10px',
    fontFamily: 'var(--font-body), "Source Sans 3", sans-serif',
  },
  elements: {
    avatarBox: {
      width: '2rem',
      height: '2rem',
    },
    userButtonPopoverCard: {
      background: '#12141c',
      border: '1px solid #2a2d3a',
      boxShadow: '0 16px 40px rgba(0, 0, 0, 0.55)',
      color: '#f4f5f5',
    },
    userButtonPopoverMain: {
      background: '#12141c',
      color: '#f4f5f5',
    },
    userButtonPopoverActions: {
      background: '#12141c',
    },
    userButtonPopoverActionButton: {
      color: '#f4f5f5',
    },
    userButtonPopoverActionButtonText: {
      color: '#f4f5f5',
    },
    userButtonPopoverActionButtonIcon: {
      color: '#a8aebc',
    },
    userPreviewMainIdentifier: {
      color: '#f4f5f5',
    },
    userPreviewSecondaryIdentifier: {
      color: '#a8aebc',
    },
    userButtonPopoverFooter: {
      display: 'none',
    },
  },
} as const;
