"use client";

import { useEffect, useState } from "react";

export default function GithubStarButton() {
  const [stars, setStars] = useState<number | null>(null);

  useEffect(() => {
    fetch("https://api.github.com/repos/kitsunekode/hyprland-caffeine-mode")
      .then((res) => res.json())
      .then((data) => {
        if (data.stargazers_count !== undefined) {
          setStars(data.stargazers_count);
        }
      })
      .catch((err) => console.error("Failed to fetch GitHub stars:", err));
  }, []);

  return (
    <a 
      href="https://github.com/kitsunekode/hyprland-caffeine-mode" 
      target="_blank" 
      rel="noopener noreferrer"
      className="btn github-btn"
      aria-label="Star on GitHub"
    >
      <span className="coord-label top-right">SRC_CODE</span>
      <span className="coord-label bottom-left">GITHUB</span>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true" style={{ marginRight: '0.5rem' }}>
        <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" />
      </svg>
      GITHUB
      {stars !== null && (
        <span style={{ 
          marginLeft: '0.5rem', 
          paddingLeft: '0.5rem', 
          borderLeft: '1px solid var(--border-focus)',
          color: 'var(--text-primary)',
          display: 'flex',
          alignItems: 'center',
          gap: '0.25rem'
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="none" aria-hidden="true">
            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
          </svg>
          {stars}
        </span>
      )}
    </a>
  );
}