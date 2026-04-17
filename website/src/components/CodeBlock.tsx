"use client";

import { useState } from "react";

export default function CodeBlock({ code, language = "bash" }: { code: string; language?: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error("Failed to copy text", err);
    }
  };

  return (
    <div className="code-block">
      <div className="code-block-header">
        <span className="lang-label">{language}</span>
        <button 
          onClick={handleCopy} 
          className={`copy-btn ${copied ? "copied" : ""}`}
          aria-label="Copy to clipboard"
        >
          {copied ? "COPIED" : "COPY"}
        </button>
      </div>
      <pre><code>{code}</code></pre>
    </div>
  );
}