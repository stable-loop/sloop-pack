# frozen_string_literal: true

module Package
  CONFIG = {
    name: "Repebox",
    version: "1.0.0",
    url: "https://repebox.com",
    summary: "Repebox worship songs and resources",
    description: [
      "Repebox provides songs, chords, lyrics, screen jumps and worship resources",
      "for churches and worship teams."
    ].join(" "),
    id: "com.repebox.app",
    tag: "repebox",
    developer: "Stableloop.dev",
    email: "support@stableloop.dev",
    category: "Utility",
    icon: "public/icon_mobile.png",
    rendered_directory: "tmp/packages",
    # Electron generates desktop packages for Windows, macOS and Linux.
    # Based on Chromium and Node.js. With heavy weights.
    electron: {
      window_height: 900,
      window_min_height: 600,
      window_min_width: 800,
      window_width: 1280
    },
    # Tauri generates desktop packages for Windows, macOS and Linux.
    # Based on Webview and Rust. With light weights.
    tauri: {
      window_height: 900,
      window_min_height: 600,
      window_min_width: 800,
      window_width: 1280,
      target_directory: "tmp/tauri/target",
      project_directory: "tmp/tauri/project",
      tauri_cli: "node_modules/@tauri-apps/cli/tauri.js"
    },
    # Capacitor generates mobile packages for Android and iOS.
    capacitor: {
      web_dir: "tmp/www",
      android_path: "tmp/android",
      android_project_directory: "tmp/android",
      capacitor_assets_directory: "assets",
      gradle_wrapper: "tmp/android/gradlew",
      keystore_filename: "release.keystore",
      keystore_key_alias: "repebox",
      keystore_validity_days: "100000",
      keystore_password: Cred[:android_keystore_password],
      keystore_key_password: Cred[:android_key_password]
    },
    # S3 to upload public packages.
    s3: {
      bucket: "stableloop-public",
      endpoint: "https://s3.fr-par.scw.cloud",
      region: "fr-par",
      prefix: "repebox/",
      access_key_id: Cred[:s3_access_key_id],
      secret_access_key: Cred[:s3_secret_access_key]
    }
  }.freeze
end
