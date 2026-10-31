import { useState } from "react";
import { invoke } from "@tauri-apps/api/core";

type InstagramMode = "desktop" | "mobile";

const modes: Array<{
  id: InstagramMode;
  eyebrow: string;
  title: string;
  description: string;
  badge: string;
}> = [
  {
    id: "desktop",
    eyebrow: "FULL WIDTH",
    title: "Desktop Instagram",
    description:
      "Open the normal Instagram web experience in its own native desktop window.",
    badge: "Stable baseline",
  },
  {
    id: "mobile",
    eyebrow: "MOBILE WEB",
    title: "Mobile Instagram",
    description:
      "Launch Instagram with a mobile browser identity so we can test mobile-only features such as Story creation.",
    badge: "Story experiment",
  },
];

function App() {
  const [opening, setOpening] = useState<InstagramMode | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function openInstagram(mode: InstagramMode) {
    setOpening(mode);
    setError(null);

    try {
      await invoke("open_instagram", { mode });
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setOpening(null);
    }
  }

  return (
    <main className="app-shell">
      <section className="hero">
        <div className="brand-row">
          <div className="brand-mark" aria-hidden="true">
            IG
          </div>
          <div>
            <p className="kicker">IG DESKTOP · v0.1</p>
            <h1>Instagram for PC, without the missing pieces.</h1>
          </div>
        </div>

        <p className="hero-copy">
          This launcher opens the real Instagram website inside native Tauri
          windows. Nothing here replaces Instagram accounts, posts, DMs, or
          servers — we are improving the desktop client around them.
        </p>

        <div className="mode-grid">
          {modes.map((mode) => (
            <article className="mode-card" key={mode.id}>
              <div className="card-topline">
                <span>{mode.eyebrow}</span>
                <span className="badge">{mode.badge}</span>
              </div>
              <h2>{mode.title}</h2>
              <p>{mode.description}</p>
              <button
                type="button"
                onClick={() => openInstagram(mode.id)}
                disabled={opening !== null}
              >
                {opening === mode.id ? "Opening…" : `Open ${mode.title}`}
              </button>
            </article>
          ))}
        </div>

        {error && <p className="error-box">Could not open Instagram: {error}</p>}

        <div className="status-strip">
          <span className="status-dot" />
          <span>
            Phase 1: prove login/session persistence and Story availability in
            mobile mode.
          </span>
        </div>
      </section>
    </main>
  );
}

export default App;
