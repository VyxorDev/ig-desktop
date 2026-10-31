# IG Desktop

A lightweight experimental desktop client for the **real Instagram web experience**, built with Tauri, React, TypeScript, Rust, and Windows WebView2.

IG Desktop does **not** recreate Instagram, host user accounts, proxy credentials, or maintain its own social backend. The current prototype opens `instagram.com` directly inside native Tauri webview windows.

> **Status:** very early v0.1 proof of concept.

## Why

Instagram's desktop experience still trails the mobile experience in several places. IG Desktop explores whether a lightweight native client can provide a better PC workflow while continuing to use Instagram's own website and account/session system.

The first experiment is Story creation: the launcher can open Instagram in both a normal desktop webview and a mobile-identified webview so their behavior can be compared directly.

## v0.1

- Native Tauri launcher
- Real `instagram.com` desktop window
- Separate mobile-web Instagram window
- Mobile user-agent experiment for mobile-only web features
- Normal Instagram login/session handled by Instagram inside WebView2
- No private Instagram API
- No custom backend

## Run locally

### Requirements

- Windows 10/11
- Node.js + npm
- Rust toolchain
- Microsoft Edge WebView2 Runtime
- Tauri's Windows build prerequisites

### Start

```powershell
git clone https://github.com/VyxorDev/ig-desktop.git
cd ig-desktop
npm install
npm run tauri dev
```

The launcher provides two modes:

- **Desktop Instagram** — normal desktop web identity and a wide native window.
- **Mobile Instagram** — Android mobile browser identity in a phone-shaped native window for testing mobile web functionality.

## Current milestone

We need to verify three things before building higher-level desktop features:

1. Instagram login works reliably inside WebView2.
2. The Instagram session persists across app restarts/windows.
3. Mobile mode exposes Story creation and Windows file selection can complete an actual Story upload.

Only after those are proven should the project depend on that route for Story support.

## Direction

If the proof works, likely next steps include a polished single-window desktop shell, navigation controls, notifications, media drag-and-drop, account switching, and safer handling of links/popups.

## Disclaimer

IG Desktop is an independent, unofficial project. It is not affiliated with, endorsed by, or sponsored by Instagram or Meta. Instagram and related marks belong to their respective owners.

## License

MIT
