import { ImageResponse } from 'next/og';

export const dynamic = 'force-static';

export const alt = 'Hyprland Caffeine Mode';
export const size = {
  width: 1200,
  height: 630,
};
export const contentType = 'image/png';

export default async function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          backgroundColor: '#050505',
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          fontFamily: 'monospace',
          position: 'relative',
        }}
      >
        {/* Grid Background */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundImage: 'linear-gradient(to right, #111 1px, transparent 1px), linear-gradient(to bottom, #111 1px, transparent 1px)',
            backgroundSize: '40px 40px',
            opacity: 0.5,
          }}
        />
        
        {/* Content Box */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-start',
            justifyContent: 'center',
            border: '2px solid #222',
            padding: '60px 80px',
            background: '#050505',
            position: 'relative',
            width: '80%',
            height: '60%',
          }}
        >
          {/* Accent border top */}
          <div style={{ position: 'absolute', top: -2, left: 0, right: 0, height: 4, background: '#d4af37' }} />
          
          <div style={{ color: '#d4af37', fontSize: 24, letterSpacing: '0.2em', marginBottom: 30, display: 'flex' }}>
            SYSTEM.OUT // HYPRLAND
          </div>
          <div style={{ color: '#fff', fontSize: 72, fontWeight: 'bold', letterSpacing: '-0.02em', marginBottom: 20, display: 'flex' }}>
            CAFFEINE MODE
          </div>
          <div style={{ color: '#888', fontSize: 32, maxWidth: 800, display: 'flex' }}>
            The Ultimate Systemd-Driven Idle Inhibitor
          </div>

          <div style={{ position: 'absolute', bottom: 30, right: 40, color: '#444', fontSize: 20, display: 'flex' }}>
            v1.0.0 // KITSUNELABS
          </div>
          <div style={{ position: 'absolute', top: 30, right: 40, color: '#d4af37', fontSize: 20, display: 'flex' }}>
            [ ACTIVE ]
          </div>
        </div>
      </div>
    ),
    {
      ...size,
    }
  );
}