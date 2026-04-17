"use client";

import { useRef } from "react";
import gsap from "gsap";
import { useGSAP } from "@gsap/react";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import CodeBlock from "@/components/CodeBlock";
import GithubStarButton from "@/components/GithubStarButton";

if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger, useGSAP);
}

export default function Home() {
  const container = useRef<HTMLDivElement>(null);

  useGSAP(
    () => {
      // Initial Hero Animation
      const tl = gsap.timeline();

      tl.fromTo(
        ".problem-statement span.block",
        { y: 50, opacity: 0 },
        { y: 0, opacity: 1, stagger: 0.15, duration: 0.8, ease: "power3.out" },
      )
        .fromTo(
          ".hero-btn, .github-btn",
          { opacity: 0, x: -20 },
          { opacity: 1, x: 0, stagger: 0.15, duration: 0.5, ease: "power2.out" },
          "-=0.4",
        )
        .fromTo(
          ".detail-card.hero-card",
          { opacity: 0, y: 30 },
          { opacity: 1, y: 0, stagger: 0.1, duration: 0.6, ease: "power2.out" },
          "-=0.2",
        );

      // Scroll Animations
      gsap.utils.toArray<HTMLElement>(".section").forEach((section) => {
        const title = section.querySelector(".section-title");
        const content = section.querySelector(".section-content");

        if (title) {
          gsap.fromTo(
            title,
            { opacity: 0, x: -50 },
            {
              opacity: 1,
              x: 0,
              duration: 0.8,
              ease: "power2.out",
              scrollTrigger: {
                trigger: section,
                start: "top 80%",
              },
            },
          );
        }

        if (content) {
          gsap.fromTo(
            content,
            { opacity: 0, y: 30 },
            {
              opacity: 1,
              y: 0,
              duration: 0.8,
              ease: "power2.out",
              delay: 0.2,
              scrollTrigger: {
                trigger: section,
                start: "top 80%",
              },
            },
          );
        }
      });
    },
    { scope: container },
  );

  return (
    <main ref={container} className="container">
      <section className="hero">
        <h1 className="problem-statement">
          <span className="block" style={{ display: "block" }}>
            Hyprland is brilliant.
          </span>
          <span className="block" style={{ display: "block" }}>
            Your screen sleeping
          </span>
          <span className="block problem-highlight" style={{ display: "block" }}>
            during a 20-minute compilation
          </span>
          <span className="block" style={{ display: "block" }}>
            is infuriating.
          </span>
        </h1>

        <div style={{ display: "flex", gap: "1rem", flexWrap: "wrap" }}>
          <a
            href="#install"
            className="btn hero-btn"
            aria-label="Deploy Caffeine Mode Installation Instructions"
          >
            <span className="coord-label top-right">INIT_SEQ</span>
            <span className="coord-label bottom-left">v1.0.0</span>
            DEPLOY CAFFEINE MODE
            <svg
              width="20"
              height="20"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              aria-hidden="true"
            >
              <path d="M5 12h14M12 5l7 7-7 7" />
            </svg>
          </a>
          <GithubStarButton />
        </div>

        <div className="details-grid">
          <div className="detail-card hero-card">
            <span className="coord-label top-right">ERR_01</span>
            <h3 className="detail-title">The Issue</h3>
            <p className="detail-desc">
              Standard idle inhibitors fail to recognize long-running background tasks, watching
              videos, or reading documentation, causing the display manager to power down the screen
              prematurely.
            </p>
          </div>
          <div className="detail-card hero-card">
            <span className="coord-label top-right">SYS_02</span>
            <h3 className="detail-title">The Solution</h3>
            <p className="detail-desc">
              A deep system-level integration with Hyprland and Waybar that provides deterministic,
              persistent idle inhibition precisely when you require it, without draining battery
              when you don&apos;t.
            </p>
          </div>
          <div className="detail-card hero-card">
            <span className="coord-label top-right">OPT_03</span>
            <h3 className="detail-title">The Architecture</h3>
            <p className="detail-desc">
              Engineered purely in Bash and Systemd. No heavy background daemons, no memory leaks.
              Just pure, precise execution.
            </p>
          </div>
        </div>
      </section>

      <section className="section" id="features">
        <h2 className="section-title">Core Specifications</h2>
        <div
          className="section-content details-grid"
          style={{ marginTop: 0, borderTop: "none", paddingTop: 0 }}
        >
          <div className="detail-card">
            <span className="coord-label top-right">FEAT_A</span>
            <h3 className="detail-title">Waybar Integration</h3>
            <p className="detail-desc">
              A custom Waybar module that displays the current inhibition state with absolute
              clarity. One click to toggle.
            </p>
          </div>
          <div className="detail-card">
            <span className="coord-label top-right">FEAT_B</span>
            <h3 className="detail-title">Systemd Orchestration</h3>
            <p className="detail-desc">
              Managed via standard systemd user services for reliable startup, dependency
              management, and robust lifecycle control.
            </p>
          </div>
        </div>
      </section>

      <section className="section" id="dilemma">
        <h2 className="section-title">The Waybar Dilemma</h2>
        <div className="section-content">
          <p
            className="detail-desc"
            style={{ marginBottom: "2rem", maxWidth: "800px", fontSize: "1.1rem", color: "#fff" }}
          >
            Why not just use Waybar&apos;s built-in{" "}
            <code style={{ color: "var(--accent)" }}>idle_inhibitor</code> module?
          </p>
          <div className="details-grid" style={{ marginTop: 0, borderTop: "none", paddingTop: 0 }}>
            <div className="detail-card">
              <span className="coord-label top-right">CRASH_VULN</span>
              <h3 className="detail-title">Volatile State</h3>
              <p className="detail-desc">
                If Waybar crashes or you reload your theme, the built-in module resets to its
                default (inactive) state. Your session is suddenly unprotected, and you receive no
                warning.
              </p>
            </div>
            <div className="detail-card">
              <span className="coord-label top-right">ISO_STATE</span>
              <h3 className="detail-title">Isolated Context</h3>
              <p className="detail-desc">
                The built-in toggle is purely internal to Waybar. You cannot bind a Hyprland
                keyboard shortcut to toggle it, nor can external scripts read its current status.
              </p>
            </div>
            <div className="detail-card" style={{ borderColor: "var(--accent)" }}>
              <span
                className="coord-label top-right"
                style={{ color: "var(--accent)", opacity: 1 }}
              >
                SOLUTION
              </span>
              <h3 className="detail-title" style={{ color: "var(--accent)" }}>
                Single Source of Truth
              </h3>
              <p className="detail-desc" style={{ color: "#ccc" }}>
                Caffeine Mode solves this by moving the state into a{" "}
                <code style={{ color: "#fff" }}>systemd --user</code> service. Waybar, keybinds, and
                scripts all read from and write to the exact same persistent state.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="section" id="integration">
        <h2 className="section-title">System Integration</h2>
        <div
          className="section-content details-grid"
          style={{ marginTop: 0, borderTop: "none", paddingTop: 0 }}
        >
          <div>
            <h3 className="detail-title" style={{ marginBottom: "1rem" }}>
              Hyprland Keybind
            </h3>
            <p className="detail-desc" style={{ marginBottom: "1rem" }}>
              Toggle caffeine mode instantly via your keyboard. State syncs automatically to Waybar.
            </p>
            <CodeBlock
              code={`# ~/.config/hypr/hyprland.conf\nbind = $mainMod, C, exec, CAFFEINE_REQUIRE_SERVICE=1 CAFFEINE_WAYBAR_SIGNAL=20 ~/.local/bin/idle-inhibitor-toggle.sh toggle`}
            />
          </div>
          <div>
            <h3 className="detail-title" style={{ marginBottom: "1rem" }}>
              Hypridle Compatibility
            </h3>
            <p className="detail-desc" style={{ marginBottom: "1rem" }}>
              Ensure Hypridle respects systemd inhibition locks for flawless operation.
            </p>
            <CodeBlock
              code={`# ~/.config/hypr/hypridle.conf\ngeneral {\n    ignore_systemd_inhibit = false\n}`}
            />
          </div>
        </div>
      </section>

      <section className="section" id="install">
        <h2 className="section-title">Deployment Protocol</h2>
        <div className="section-content">
          <p className="detail-desc" style={{ marginBottom: "1.5rem", maxWidth: "800px" }}>
            Clone the repository and execute the installation script. The core infrastructure
            resides in the root directory, ensuring maximum compatibility with standard Hyprland
            configurations.
          </p>
          <CodeBlock
            code={`git clone https://github.com/kitsunekode/hyprland-caffeine-mode.git\ncd hyprland-caffeine-mode\n\n# Execute the deployment sequence\nchmod +x install.sh\n./install.sh`}
          />
        </div>
      </section>

      <footer className="footer">
        <p>SYSTEM.OUT // HYPRLAND CAFFEINE MODE // DESIGNED WITH PRECISION</p>
      </footer>
    </main>
  );
}

