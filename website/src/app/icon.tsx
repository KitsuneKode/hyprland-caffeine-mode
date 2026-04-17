import { ImageResponse } from 'next/og';

export const dynamic = 'force-static';

export const size = {
  width: 32,
  height: 32,
};
export const contentType = 'image/png';

export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          fontSize: 20,
          background: '#050505',
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#d4af37',
          borderTop: '3px solid #d4af37',
          borderRight: '1px solid #222',
          borderBottom: '1px solid #222',
          borderLeft: '1px solid #222',
          fontFamily: 'monospace',
          fontWeight: 'bold',
        }}
      >
        C
      </div>
    ),
    {
      ...size,
    }
  );
}