type LogoProps = {
  className?: string;
  title?: string;
};

/**
 * Course compass mark from Figma (Sailing Plans Brand).
 * Geometric four-point rose + north waypoint — original SP glyph.
 * File: https://www.figma.com/design/SrvntpWbmYhhH7ysAKby3g
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
        <path d="M32 16 39.5 30.8 34.8 34H29.2L24.5 30.8 32 16Z" />
        <path d="M52 36 38.2 28.5 35 33.2V38.8L38.2 43.5 52 36Z" />
        <path d="M32 56.5 24.5 41.2 29.2 38H34.8L39.5 41.2 32 56.5Z" />
        <path d="M12 36 25.8 28.5 29 33.2V38.8L25.8 43.5 12 36Z" />
        <circle cx="32" cy="11.5" r="5.25" />
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
