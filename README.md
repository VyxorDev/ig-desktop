# IG Desktop

A lightweight experimental desktop client for the **real Instagram web experience**, built with Tauri, React, TypeScript, Rust, and Windows WebView2.

IG Desktop does **not** recreate Instagram, host user accounts, proxy credentials, or maintain its own social backend. The current prototype opens `instagram.com` directly inside native Tauri webview windows.

> **Status:** very early v0.1 proof of concept. The current priority is proving the webview/session/Story path before adding larger desktop features.

## Why

Instagram's desktop experience still trails the mobile experience in several places. IG Desktop explores whether a lightweight native client can provide a better PC workflow while continuing to use Instagram's own website and account/session system.

The first experiment is Story creation: the launcher can open Instagram in both a normal desktop webview and a mobile-identified webview so their behavior can be compared directly.

## v0.1

- Native Tauri launcher
- Real `instagram.com` desktop window
- Separate mobile-web Instagram window
- Mobile user-agent experiment for mobile-only web features
- Normal Instagram login/session handled by Instagram inside WebView2
- Persistent WebView2 site data; IG Desktop does not store Instagram passwords itself
- Remote Instagram webviews are not granted Tauri IPC capabilities
- No private Instagram API
- No custom backend
- GitHub Actions validation for frontend and Rust

## Run locally

### Requirements

- Windows 10/11
- Node.js + npm
- Rust stable toolchain
- Microsoft Edge WebView2 Runtime
- Tauri's Windows build prerequisites (Microsoft C++ Build Tools / Windows SDK)

### Start

```powershell
git clone https://github.com/VyxorDev/ig-desktop.git
cd ig-desktop
npm install
npm run tauri dev
```

If you already cloned the project, update first:

```powershell
git pull
npm install
npm run tauri dev
```

The launcher provides two modes:

- **Desktop Instagram** — normal desktop web identity and a wide native window.
- **Mobile Instagram** — Android mobile browser identity in a phone-shaped native window for testing mobile web functionality.

## Troubleshooting

### Cargo reports a corrupted crate after an interrupted build

A hard shutdown while Cargo is downloading/unpacking a crate can leave invalid files under `.cargo\registry`. A typical symptom looks like `key with no value, expected '='`, null characters in a dependency's `Cargo.toml`, or `failed to download <crate>`.

For the known `http v1.5.0` failure, update the repo and run the targeted repair script:

```powershell
git pull
powershell -ExecutionPolicy Bypass -File .\scripts\repair-cargo-cache.ps1
npm run tauri dev
```

The script deletes only the cached `http-1.5.0` source/archive and asks Cargo to fetch a clean copy. It does **not** wipe the Rust toolchain or the whole Cargo registry.

You can target another single corrupted crate if needed:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\repair-cargo-cache.ps1 -Crate "crate-name" -Version "1.2.3"
```

## Current milestone

We need to verify four things before building higher-level desktop features:

1. The project compiles cleanly on a fresh machine/CI.
2. Instagram login works reliably inside WebView2.
3. The Instagram session persists across app restarts/windows.
4. Mobile mode exposes Story creation and Windows file selection can complete an actual Story upload.

Only after those are proven should the project depend on that route for Story support.

## Security model

The local launcher is the only window that can invoke the app's native `open_instagram` command. Instagram itself is loaded as a remote URL in separate webview windows and is not opted into any remote Tauri capability.

Authentication remains between the embedded browser and Instagram. IG Desktop does not ask for, intercept, or maintain an independent copy of the user's Instagram credentials.

## Direction

If the proof works, likely next steps include a polished single-window desktop shell, navigation controls, notifications, media drag-and-drop, account switching, safer handling of links/popups, and installable Windows builds.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the technical boundaries and [`docs/ROADMAP.md`](docs/ROADMAP.md) for the staged plan.

## Disclaimer

IG Desktop is an independent, unofficial project. It is not affiliated with, endorsed by, or sponsored by Instagram or Meta. Instagram and related marks belong to their respective owners.

The mobile-web Story path is experimental and depends on behavior controlled by Instagram. IG Desktop should not rely on undocumented private APIs for the v0.1 proof.

## License

MIT
