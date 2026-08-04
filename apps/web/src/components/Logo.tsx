type LogoProps = {
  className?: string;
  title?: string;
};

/**
 * Wake Arc mark from Figma (Sailing Plans Brand).
 * Bold open ring with gap on the right + modular wake pixels — original SP glyph
 * in the same structural language as cloud-infra marks (ring + pixels), not a copy.
 * File: https://www.figma.com/design/Fhl2D2OvJqld81HK3nZkOL
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
        <path d="M37.2 6.35A26.5 26.5 0 1 0 55.65 40.8L45.4 36.5A15.2 15.2 0 1 1 34.85 14.55Z" />
        <rect x="43.2" y="28.5" width="12" height="12" />
        <rect x="50.5" y="43" width="8" height="8" />
        <rect x="54" y="23.5" width="5.5" height="5.5" />
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
