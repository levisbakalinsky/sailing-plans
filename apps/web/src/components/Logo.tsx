type LogoProps = {
  className?: string;
  title?: string;
};

/** Course mark: horizon + arc + waypoint. */
export function LogoMark({ className, title }: LogoProps) {
  return (
    <svg
      className={className}
      viewBox="0 0 64 64"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      role={title ? 'img' : 'presentation'}
      aria-hidden={title ? undefined : true}
      aria-label={title}
    >
      <path
        d="M6 40h52"
        stroke="currentColor"
        strokeOpacity="0.28"
        strokeWidth="1.75"
        strokeLinecap="round"
      />
      <path
        d="M8 48c10-18 24-28 40-28"
        stroke="currentColor"
        strokeWidth="3"
        strokeLinecap="round"
      />
      <circle cx="48" cy="20" r="5" fill="currentColor" />
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
