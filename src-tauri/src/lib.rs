use tauri::{Manager, WebviewUrl, WebviewWindowBuilder};

const INSTAGRAM_URL: &str = "https://www.instagram.com/";
const MOBILE_USER_AGENT: &str = "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Mobile Safari/537.36";

#[tauri::command]
async fn open_instagram(app: tauri::AppHandle, mode: String) -> Result<(), String> {
    let (label, other_label, title, width, height, mobile) = match mode.as_str() {
        "desktop" => (
            "instagram-desktop",
            "instagram-mobile",
            "Instagram · Desktop",
            1180.0,
            820.0,
            false,
        ),
        "mobile" => (
            "instagram-mobile",
            "instagram-desktop",
            "Instagram · Mobile",
            480.0,
            900.0,
            true,
        ),
        _ => return Err(format!("Unsupported Instagram mode: {mode}")),
    };

    // Keep only one presentation mode alive at a time. Desktop and mobile
    // webviews share the same WebView2 browser profile, and a user-agent
    // override can also influence shared service-worker behavior.
    if let Some(other_window) = app.get_webview_window(other_label) {
        other_window.close().map_err(|error| error.to_string())?;
    }

    if let Some(window) = app.get_webview_window(label) {
        window.show().map_err(|error| error.to_string())?;
        window.set_focus().map_err(|error| error.to_string())?;
        return Ok(());
    }

    let url = INSTAGRAM_URL
        .parse()
        .map_err(|error| format!("Invalid Instagram URL: {error}"))?;

    let mut builder = WebviewWindowBuilder::new(&app, label, WebviewUrl::External(url))
        .title(title)
        .inner_size(width, height)
        .min_inner_size(390.0, 640.0)
        .resizable(true)
        .enable_clipboard_access();

    if mobile {
        builder = builder.user_agent(MOBILE_USER_AGENT);
    }

    builder.build().map_err(|error| error.to_string())?;
    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![open_instagram])
        .run(tauri::generate_context!())
        .expect("error while running IG Desktop");
}
