/** Shared DO-inspired dark field: glow, dot grid, wireframe topo mesh, scale. */

type AtmosphereProps = {
  variant?: 'auth' | 'dashboard' | 'marketing';
};

const SCALE_MARKS = [26, 50, 100, 200, 300, 400, 500, 600, 700];

/** Perspective wireframe terrain — thin teal contour ridges. */
export function TopoMesh({ className }: { className?: string }) {
  const rows = [
    'M0 42 C80 28 160 56 240 40 C320 24 400 52 480 38 C560 24 640 48 720 36 L720 120 L0 120 Z',
    'M0 54 C70 40 150 68 230 52 C310 36 390 64 470 50 C550 36 630 60 720 48 L720 120 L0 120 Z',
    'M0 66 C90 52 170 80 250 64 C330 48 410 76 490 62 C570 48 650 72 720 60 L720 120 L0 120 Z',
    'M0 78 C60 66 140 92 220 76 C300 60 380 88 460 74 C540 60 620 84 720 72 L720 120 L0 120 Z',
    'M0 88 C100 76 180 102 260 86 C340 70 420 98 500 84 C580 70 660 94 720 82 L720 120 L0 120 Z',
    'M0 96 C80 88 160 108 240 96 C320 84 400 106 480 94 C560 82 640 104 720 92 L720 120 L0 120 Z',
  ];

  const lines = [
    'M0 38 C80 24 160 52 240 36 C320 20 400 48 480 34 C560 20 640 44 720 32',
    'M0 50 C70 36 150 64 230 48 C310 32 390 60 470 46 C550 32 630 56 720 44',
    'M0 62 C90 48 170 76 250 60 C330 44 410 72 490 58 C570 44 650 68 720 56',
    'M0 74 C60 62 140 88 220 72 C300 56 380 84 460 70 C540 56 620 80 720 68',
    'M0 84 C100 72 180 98 260 82 C340 66 420 94 500 80 C580 66 660 90 720 78',
    'M0 92 C80 84 160 104 240 92 C320 80 400 102 480 90 C560 78 640 100 720 88',
    'M0 100 C90 94 180 108 270 100 C360 92 450 108 540 100 C630 92 680 104 720 98',
    // vertical mesh threads
    'M60 30 L48 110',
    'M120 22 L110 110',
    'M180 34 L172 110',
    'M240 26 L236 110',
    'M300 38 L298 110',
    'M360 24 L364 110',
    'M420 36 L428 110',
    'M480 28 L492 110',
    'M540 40 L556 110',
    'M600 30 L620 110',
    'M660 42 L682 110',
  ];

  return (
    <svg
      className={className}
      viewBox="0 0 720 120"
      preserveAspectRatio="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <defs>
        <linearGradient id="mesh-fade" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#71e5f2" stopOpacity="0.55" />
          <stop offset="70%" stopColor="#71e5f2" stopOpacity="0.18" />
          <stop offset="100%" stopColor="#71e5f2" stopOpacity="0" />
        </linearGradient>
      </defs>
      {rows.map((d) => (
        <path key={d} d={d} fill="url(#mesh-fade)" opacity="0.04" />
      ))}
      {lines.map((d) => (
        <path
          key={d}
          d={d}
          fill="none"
          stroke="#71e5f2"
          strokeOpacity="0.28"
          strokeWidth="0.7"
          vectorEffect="non-scaling-stroke"
        />
      ))}
    </svg>
  );
}

export function Atmosphere({ variant = 'auth' }: AtmosphereProps) {
  return (
    <div className={`atmosphere atmosphere-${variant}`} aria-hidden="true">
      <div className="atmosphere-field" />
      <div className="atmosphere-glow" />
      <div className="atmosphere-dots" />
      <TopoMesh className="atmosphere-mesh" />
      <ol className="atmosphere-scale">
        {SCALE_MARKS.map((mark) => (
          <li key={mark}>{mark}</li>
        ))}
      </ol>
    </div>
  );
}
