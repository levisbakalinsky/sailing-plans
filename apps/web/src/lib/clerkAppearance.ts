/**
 * Light Clerk card on the dark branded page — readable labels, inputs, and links.
 * Brand accent stays teal; avoid dashboard purple defaults.
 */
export const clerkAppearance = {
  variables: {
    colorPrimary: '#0b6e7a',
    colorDanger: '#b42318',
    colorSuccess: '#0f6b4c',
    colorWarning: '#9a6700',
    colorText: '#15201f',
    colorTextSecondary: '#3d524f',
    colorBackground: '#f4f7f6',
    colorInputBackground: '#ffffff',
    colorInputText: '#15201f',
    colorNeutral: '#15201f',
    borderRadius: '2px',
    fontFamily: 'var(--font-body), "Source Sans 3", sans-serif',
  },
  elements: {
    rootBox: {
      width: '100%',
    },
    // cardBox wraps card + "Sign up" / "Sign in" footer — keep both on light surface.
    cardBox: {
      background: '#f4f7f6',
      boxShadow: '0 18px 48px rgba(0, 0, 0, 0.35)',
      border: '1px solid rgba(244, 247, 246, 0.9)',
    },
    card: {
      background: '#f4f7f6',
      boxShadow: 'none',
    },
    headerTitle: {
      color: '#15201f',
      fontFamily: 'var(--font-display), "EB Garamond", serif',
    },
    headerSubtitle: {
      color: '#3d524f',
    },
    formFieldLabel: {
      color: '#15201f',
    },
    formFieldInput: {
      background: '#ffffff',
      color: '#15201f',
      borderColor: 'rgba(21, 32, 31, 0.18)',
    },
    footer: {
      background: '#eef3f2',
    },
    footerActionText: {
      color: '#3d524f',
    },
    footerActionLink: {
      color: '#0b6e7a',
      fontWeight: '600',
    },
    identityPreviewText: {
      color: '#15201f',
    },
    identityPreviewEditButton: {
      color: '#0b6e7a',
    },
    formButtonPrimary: {
      background: '#0b6e7a',
      color: '#f4f7f6',
      '&:hover': {
        background: '#095a64',
      },
    },
  },
} as const;
