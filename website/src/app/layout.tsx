import type { Metadata } from "next";
import { Chakra_Petch, Share_Tech_Mono } from "next/font/google";
import { Analytics } from "@vercel/analytics/next";
import "./globals.css";
const chakraPetch = Chakra_Petch({
  weight: ["300", "400", "500", "600", "700"],
  subsets: ["latin"],
  variable: "--font-heading",
});

const shareTechMono = Share_Tech_Mono({
  weight: "400",
  subsets: ["latin"],
  variable: "--font-mono",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://hyprland-caffiene-mode.kitsunelabs.xyz"),
  title: "Hyprland Caffeine Mode | Advanced Idle Inhibitor",
  description:
    "The ultimate idle inhibitor for Hyprland. Stop your screen from sleeping during critical tasks, videos, and compilations. Built with precision in Bash and Systemd.",
  keywords: [
    "hyprland",
    "idle inhibitor",
    "wayland",
    "caffeine mode",
    "waybar",
    "systemd",
    "hypridle",
    "linux desktop",
  ],
  authors: [{ name: "kitsunekode" }],
  creator: "kitsunekode",
  openGraph: {
    title: "Hyprland Caffeine Mode",
    description:
      "Advanced Idle Inhibitor for Hyprland. Never let your screen sleep at the wrong time again. Syncs perfectly with Waybar and Systemd.",
    url: "https://hyprland-caffiene-mode.kitsunelabs.xyz",
    siteName: "Hyprland Caffeine Mode",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "Hyprland Caffeine Mode",
    description: "The ultimate idle inhibitor for Hyprland, Hypridle, and Waybar.",
    creator: "@kitsunekode",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${chakraPetch.variable} ${shareTechMono.variable}`}>
      <body>
        <div className="bg-grid"></div>
        <div className="bg-vignette"></div>
        {children}
        <Analytics />
      </body>
    </html>
  );
}

