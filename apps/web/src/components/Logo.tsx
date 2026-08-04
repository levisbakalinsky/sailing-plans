type LogoProps = {
  className?: string;
  title?: string;
};

/**
 * Course compass mark: geometric four-point rose with a north waypoint.
 * Original Sailing Plans glyph — bold, minimal, readable at small sizes.
 */
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
      <g fill="currentColor">
        <path d="M32 16 39.5 30.8 34.8 34 29.2 34 24.5 30.8Z" />
        <circle cx="32" cy="11.5" r="5.25" />
        <path d="M52 36 38.2 28.5 35 33.2 35 38.8 38.2 43.5Z" />
        <path d="M32 56.5 24.5 41.2 29.2 38 34.8 38 39.5 41.2Z" />
        <path d="M12 36 25.8 28.5 29 33.2 29 38.8 25.8 43.5Z" />
      </g>
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
