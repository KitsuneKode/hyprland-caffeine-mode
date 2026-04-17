# Hyprland Caffeine Mode - Website

This is the promotional website and homepage for **Hyprland Caffeine Mode**. It is a statically generated React application built with Next.js and animated with GSAP.

## Tech Stack

- **Framework:** Next.js (App Router, Static Export)
- **Styling:** Vanilla CSS (`globals.css`)
- **Animation:** GSAP (`@gsap/react`, `ScrollTrigger`)
- **Package Manager:** `bun` (or `pnpm`)

## Development

First, ensure you have [bun](https://bun.sh/) installed. Alternatively, you can use `pnpm`.

Install the dependencies:

```bash
bun install
# or
pnpm install
```

Run the development server:

```bash
bun run dev
# or
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Production Build

Because this site is built for maximum SEO and performance without requiring a Node.js server, it uses Next.js static export (`output: "export"`). 

To build the static HTML, CSS, and JavaScript files:

```bash
bun run build
# or
pnpm build
```

This will create an `out/` directory containing the fully compiled static assets. You can deploy this folder to any static hosting provider (GitHub Pages, Cloudflare Pages, Vercel, Nginx, Apache, etc.).

## Architecture Notes

- **Aesthetics:** The design uses an "Industrial/Utilitarian" dark mode, fitting the technical nature of Hyprland.
- **GSAP:** All animations are handled via the `@gsap/react` `useGSAP` hook inside `src/app/page.tsx`. Scroll-linked reveals are powered by `ScrollTrigger`.
- **No SSR:** Server-Side Rendering is disabled. The site relies entirely on Static Site Generation (SSG) for SEO, passing generated HTML to search engine crawlers instantly.