# Roadmap

IG Desktop should advance only after each layer is proven. The project is intentionally avoiding a large feature build before the core webview path is validated.

## Phase 0 — Build reliability

Goal: a clean checkout compiles consistently.

- [x] Tauri + React + TypeScript project skeleton
- [x] Stable Rust toolchain declaration
- [x] GitHub Actions validation
- [x] Targeted Cargo cache repair utility
- [ ] Generate and commit `package-lock.json`
- [ ] Generate and commit `src-tauri/Cargo.lock`
- [ ] Confirm CI passes on `main`
- [ ] Confirm clean Windows development build

## Phase 1 — Instagram proof

Goal: prove that the real Instagram web application is viable inside WebView2.

- [ ] Desktop mode loads `instagram.com`
- [ ] Instagram login succeeds
- [ ] Session survives closing/reopening the app
- [ ] Mobile mode renders the mobile web experience
- [ ] Story creation control is available in mobile mode
- [ ] Windows file picker can select Story media
- [ ] A test Story can be published to the real account
- [ ] DMs, Reels, profiles, and normal navigation remain usable

**Exit condition:** Story upload and session persistence both work reliably enough to justify the project.

## Phase 2 — Desktop shell

Goal: turn the proof into a pleasant daily desktop client without rebuilding Instagram itself.

Potential work:

- single primary Instagram window
- compact app chrome
- back / forward / refresh controls
- desktop ↔ mobile presentation toggle where useful
- open external non-Instagram links safely
- keyboard shortcuts
- remember window size/position
- graceful offline/error state
- clearer update/about/debug information

## Phase 3 — Desktop-native conveniences

Only pursue features that can be implemented without exposing broad native privileges to remote Instagram content.

Potential work:

- native notifications after security/behavior testing
- drag-and-drop media workflow
- quick Story entry point
- media upload helpers
- account/session profile isolation if multi-account support needs it
- optional tray behavior

## Phase 4 — Distribution

Goal: make the app installable by non-developers.

- Windows installer
- application icon and branding
- release workflow
- checksums
- versioned GitHub Releases
- update strategy
- code-signing evaluation (optional until distribution scale justifies cost)

## Non-goals for now

- rebuilding Instagram's backend
- custom user/follower/post database
- collecting Instagram credentials ourselves
- automating engagement, mass actions, scraping, or bot behavior
- undocumented private Instagram API dependency
- cloning Instagram's entire frontend in React

## Decision gate

If Instagram removes or blocks the mobile-web Story flow, stop and reassess before adding workarounds. The project should remain maintainable and safe rather than becoming an arms race against Instagram internals.
