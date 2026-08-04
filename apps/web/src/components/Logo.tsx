type LogoProps = {
  className?: string;
  title?: string;
};

/**
 * Sail mark from Figma Make (Neighborhood social app brand exploration).
 * Mast + leech as one continuous stroke; shallow hull arc below.
 * File: https://www.figma.com/make/ASTruHzieF3kIyUnym5Ulz/Neighborhood-social-app
 * Source node: 0:1 (Make App.tsx SailMark)
 */
export function LogoMark({ className, title }: LogoProps) {
  return (
    <svg
      className={className}
      viewBox="0 0 200 200"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      role={title ? 'img' : 'presentation'}
      aria-hidden={title ? undefined : true}
      aria-label={title}
    >
      {/* Mast + leech — one continuous path, round joins/caps */}
      <path
        d="M 88 168 L 88 30 A 100 100 0 0 1 170 158"
        stroke="currentColor"
        strokeWidth="20"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      {/* Hull — shallow arc below mast foot */}
      <path
        d="M 50 162 Q 109 182 168 162"
        stroke="currentColor"
        strokeWidth="20"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function LogoLockup({ className }: { className?: string }) {
  return (
    <span className={className ?? 'logo-lockup'}>
      <LogoMark className="logo-mark" title="Sailing Plans" />
      <span className="logo-wordmark">Sailing Plans</span>
    </span>
  );
}
