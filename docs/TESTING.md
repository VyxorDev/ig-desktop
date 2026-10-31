# Manual testing

This project wraps the real Instagram website, so the v0.1 proof needs a small amount of manual testing in an actual Windows WebView2 session. Do not treat a successful compile as proof that Instagram itself exposes every mobile feature.

## Before testing

1. Pull the latest `main` branch.
2. Run the Windows environment doctor:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
   ```

3. If the doctor reports the known corrupted `http-1.5.0` cache, run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\repair-cargo-cache.ps1
   ```

4. Install/update JavaScript dependencies and launch the app:

   ```powershell
   npm install
   npm run tauri dev
   ```

For the first Instagram experiments, use an account you are comfortable testing with. IG Desktop uses Instagram's real website, but the mobile presentation path is unofficial and can change independently of this project.

## Test A — desktop mode

- [ ] Launcher opens normally.
- [ ] Clicking **Desktop Instagram** creates one Instagram window.
- [ ] `instagram.com` loads without a certificate/network error.
- [ ] Login succeeds using Instagram's own login UI.
- [ ] Feed loads.
- [ ] Profiles open.
- [ ] Reels play.
- [ ] DMs open and existing conversations render.
- [ ] Closing and reopening Desktop Instagram keeps the session logged in.
- [ ] Closing the entire app, relaunching, and opening Desktop Instagram keeps the session logged in.

## Test B — mobile presentation

Close Desktop Instagram first. The app now enforces one presentation mode at a time because both windows share the same WebView2 browser profile and mobile mode overrides the browser user-agent.

- [ ] Clicking **Mobile Instagram** opens a phone-sized Instagram window.
- [ ] The existing Instagram session is reused.
- [ ] Instagram renders its mobile web presentation.
- [ ] Story creation / **Your story** / equivalent creation entry point is visible.
- [ ] Clicking the Story creation entry point opens a Windows file picker when media is requested.
- [ ] A normal JPG/PNG can be selected.
- [ ] Instagram reaches its Story preview/editor step.
- [ ] A disposable test Story can be published.
- [ ] The published Story appears in the official Instagram phone app or normal browser session for the same account.
- [ ] Delete the disposable Story after verification if desired.

## Test C — mode switching

- [ ] Open Desktop Instagram.
- [ ] Return to the launcher and choose Mobile Instagram.
- [ ] Desktop Instagram closes and Mobile Instagram opens.
- [ ] Return to the launcher and choose Desktop Instagram.
- [ ] Mobile Instagram closes and Desktop Instagram opens.
- [ ] Login state remains intact across both switches.

## Test D — failure behavior

Record the exact behavior rather than guessing at the cause.

- If login is blocked, note the full Instagram message shown in the webview.
- If Story creation is absent, record whether the rest of the page looks mobile or desktop.
- If the file picker never opens, record what happens immediately after pressing the upload control.
- If a link opens a new window or leaves Instagram unexpectedly, record the destination domain.
- If the native app crashes, capture the PowerShell/Rust output from the terminal running `npm run tauri dev`.

## Pass criteria for the v0.1 proof

The proof is considered viable only when all of these are true:

1. A clean Windows build succeeds.
2. Instagram login works inside WebView2.
3. Session state survives a full app restart.
4. Mobile mode exposes a Story creation path.
5. Windows media selection works.
6. A Story posted through the embedded Instagram mobile web UI appears on the real Instagram account.

If item 4, 5, or 6 consistently fails because Instagram no longer exposes the functionality on mobile web, stop and reassess the architecture rather than adding undocumented/private API workarounds by default.
