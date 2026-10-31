# Architecture

IG Desktop is intentionally a thin desktop client around Instagram's real web application. The project should add desktop ergonomics without becoming an Instagram backend, credential proxy, or private-API client.

## Components

```text
┌──────────────────────────────────────────────┐
│ Local launcher (React + Vite)               │
│                                              │
│ Can invoke: open_instagram(mode)            │
└──────────────────────┬───────────────────────┘
                       │ Tauri IPC
                       ▼
┌──────────────────────────────────────────────┐
│ Native layer (Rust + Tauri)                 │
│                                              │
│ Creates/focuses Instagram WebView2 windows  │
└──────────────┬─────────────────┬─────────────┘
               │                 │
               ▼                 ▼
    Desktop Instagram      Mobile Instagram
    normal web identity    mobile user-agent
               │                 │
               └────────┬────────┘
                        ▼
                 instagram.com
```

## Trust boundaries

### Local launcher

The bundled launcher is trusted application code. Its Tauri capability targets only the `main` window and allows the custom `open_instagram` command.

### Instagram webviews

Instagram is remote third-party content. These webviews are **not** included in a remote Tauri capability and therefore must not receive access to native application commands or plugins.

Do not add a capability such as:

```json
{
  "remote": { "urls": ["https://*.instagram.com"] }
}
```

unless a future feature has a concrete, narrowly scoped requirement and a security review has been done first.

## Authentication and session data

Authentication happens inside Instagram's own website. IG Desktop should never collect an Instagram password in a custom form.

On Windows, Tauri/WebView2 persists browser state in the app's local webview data directory. Cookies and other site storage therefore remain browser-managed rather than duplicated into a project database.

The desktop and mobile windows currently share the app's normal browser data store so a login can be reused between modes.

## Story experiment

The v0.1 mobile mode changes the browser user-agent and uses a phone-sized window. The purpose is to test whether Instagram's mobile web application exposes Story creation and whether its standard HTML file picker can accept a Windows file through WebView2.

This is an experiment, not a guaranteed API contract. Instagram can change mobile-web behavior at any time.

The project should prefer this order of approaches:

1. Public Instagram web behavior.
2. Official Meta APIs where they apply and do not exclude the target account type/use case.
3. Do not use undocumented private/mobile APIs merely to force feature parity.

## Native API policy

Keep native commands minimal. If new capabilities are required later:

- grant them only to local bundled UI when possible;
- scope file access to user-selected paths;
- do not expose shell/process/filesystem capabilities directly to Instagram pages;
- treat all data read from a remote webview as untrusted input.

## Dependency policy

- Tauri 2.x stable is the native framework for the current project.
- Rust uses the stable toolchain declared in `rust-toolchain.toml`.
- CI must run frontend type/build validation plus `cargo fmt`, `cargo check`, and `cargo clippy`.
- Commit dependency lockfiles once generated successfully on a clean build so installs are reproducible.

## What belongs in Rust vs frontend

Use Rust/Tauri for operating-system boundaries: windows, permissions, persistent app settings, notifications, safe file-system bridges, and packaging.

Use React/TypeScript for the local launcher/control surface only. Do not attempt to rebuild Instagram's feed or scrape it into our own React UI unless there is a strong reason; that would dramatically increase fragility and maintenance cost.
