module Package
  module Config
    # Electron generates desktop packages for Windows, macOS and Linux.
    # Based on Chromium and Node.js. With heavy weights.
    ELECTRON = {
      window_height: 900,
      window_min_height: 600,
      window_min_width: 800,
      window_width: 1280
    }.freeze
    # Tauri generates desktop packages for Windows, macOS and Linux.
    # Based on Webview and Rust. With light weights.
    TAURI = {
      category: "Utility",
      window_height: 900,
      window_min_height: 600,
      window_min_width: 800,
      window_width: 1280,
      target_directory: "tmp/tauri/target",
      project_directory: "tmp/tauri/project",
      tauri_cli: "node_modules/@tauri-apps/cli/tauri.js"
    }.freeze
    # Capacitor generates mobile packages for Android and iOS.
    CAPACITOR = {
      web_dir: "tmp/www",
      android_path: "tmp/android",
      android_project_directory: "tmp/android",
      capacitor_assets_directory: "assets",
      gradle_wrapper: "tmp/android/gradlew",
      keystore_filename: "repebox-release.keystore",
      keystore_key_alias: "repebox",
      keystore_validity_days: "100000",
      keystore_password: Cred[:android_keystore_password],
      keystore_key_password: Cred[:android_key_password]
    }.freeze
    # S3 to upload public packages.
    S3 = {
      bucket: "stableloop-public",
      endpoint: "https://s3.fr-par.scw.cloud",
      region: "fr-par",
      prefix: "repebox/",
      access_key_id: Cred[:s3_access_key_id],
      secret_access_key: Cred[:s3_secret_access_key]
    }.freeze
    # Github Actions generates downloadable packages for Android, Windows, macOS and Linux.
    # Downloadable packages are stored in a public S3 bucket.
    GITHUB = {
      downloads: [
        {
          platform: :android,
          icon: "android",
          filename: "repebox.apk",
          url: "https://stableloop-public.s3.fr-par.scw.cloud/repebox/repebox.apk"
        },
        {
          platform: :windows,
          icon: "windows",
          filename: "Repebox_1.0.0_x64-setup.exe",
          url: "https://stableloop-public.s3.fr-par.scw.cloud/repebox/Repebox_1.0.0_x64-setup.exe"
        },
        {
          platform: :macos,
          icon: "apple",
          filename: "Repebox-1.0.0-arm64.dmg",
          url: "https://stableloop-public.s3.fr-par.scw.cloud/repebox/Repebox-1.0.0-arm64.dmg"
        },
        {
          platform: :linux,
          icon: "ubuntu",
          filename: "repebox_1.0.0_amd64.deb",
          url: "https://stableloop-public.s3.fr-par.scw.cloud/repebox/repebox_1.0.0_amd64.deb"
        }
      ]
    }.freeze

    VALUES = {
      app_name: "Repebox",
      version: "1.0.0",
      app_url: "https://repebox.com",
      summary: "Repebox worship songs and resources",
      description: "Repebox provides songs, chords, lyrics, screen jumps and worship resources for churches and worship teams.",
      app_id: "com.repebox.app",
      product_tag: "repebox",
      developer: "Repebox.com",
      public_icon: "public/icon_mobile.png",
      rendered_directory: "tmp/packages",
      capacitor: CAPACITOR,
      electron: ELECTRON,
      github: GITHUB,
      tauri: TAURI
    }.freeze
  end
end
