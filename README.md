# sloop-pack

This gem generates the necessary build files and packages for Debian, Windows, Mac and Android, and provides tasks to upload the resulting packages to S3. Also included are GitHub Actions workflows to build and upload packages on demand.

## Installation

Add `sloop-pack` to the Gemfile:

```ruby
gem "sloop-pack", git: "git@github.com:stable-loop/sloop-pack.git"
```

Run `bundle install`, then initialize the packaging files and install the
JavaScript dependencies:

```bash
sloop-pack init
```

The initializer installs `config/packages/config.rb`, the root
`capacitor.config.ts` wrapper and the GitHub workflows. It also adds the
required packaging scripts, dependencies and build paths to `package.json`.
Package views remain inside the gem and are never copied into the application.
Existing files and package scripts are never overwritten.

Package templates are rendered into the configured `rendered_directory` (normally
`tmp/packages/`) using the values in the consuming project's
`config/packages/config.rb`. The Android signing keystore remains in the
consuming project.

## Electron

Electron packages use Chromium and open the hosted application. After installing
the JavaScript dependencies, build locally with:

```bash
bundle exec rake electron:build:deb
bundle exec rake electron:build:win
bundle exec rake electron:build:mac
```

Electron builds use `tmp/electron/` and copy the resulting package to `public/`.
The Electron profile is separate from the browser profile and persists cookies,
Service Worker cache and IndexedDB data between launches.

GitHub Actions builds can be started and downloaded locally with:

```bash
bundle exec rake github:build:deb
bundle exec rake github:build:win
bundle exec rake github:build:mac
```

These tasks require an authenticated GitHub CLI (`gh auth login`) and invoke the
corresponding manually triggered workflow.

## Tauri

Tauri is a lightweight alternative to Electron using the operating system
WebView instead of bundling Chromium:

```bash
bundle exec rake tauri:build:deb
bundle exec rake tauri:build:win
bundle exec rake tauri:build:mac
```

Tauri requires Rust, Cargo, the Tauri CLI and the platform WebView prerequisites.
Build files are generated under `tmp/tauri/` and packages are copied to `public/`.
Windows and macOS builds require their native toolchains or a CI runner.

## Capacitor

Build a signed Android APK locally with:

```bash
cp /path/to/repebox.keystore config/packages/repebox-release.keystore
bundle exec rake capacitor:build:apk
```

The Android project is generated under `tmp/android/`. The release APK is signed
with `zipalign` and `apksigner`, which must be available on `PATH`, and copied to
`public/`. The launcher icon is generated from `public/icon_mobile.png`.

Signing values are read from the package configuration, normally backed by Rails
credentials:

- `android_keystore_password`
- `android_key_alias`
- `android_key_password`

To generate a new keystore using those configured passwords, run:

```bash
bundle exec rake g:keystore
```

The command stores the keystore under `config/packages/` and prints the values
needed to configure local builds and GitHub Actions. Keep the keystore and its
passwords secure.

Export the keystore as the GitHub Actions secret required by the Android
workflow:

```bash
base64 -w 0 config/packages/repebox-release.keystore | gh secret set ANDROID_KEYSTORE_BASE64
```

The Android package can also be built on GitHub Actions and downloaded locally:

```bash
bundle exec rake github:build:apk
```

The Android workflow requires the `RAILS_MASTER_KEY` and
`ANDROID_KEYSTORE_BASE64` repository secrets.

For Google sign-in, create an Android OAuth client for the application's package
ID and add the SHA-1 fingerprint of the signing certificate. The existing web
OAuth client ID is still required by the application.

## Other tasks

Upload a local package to the configured public S3 bucket:

```bash
bundle exec rake package:upload[file]
```

Configure the bucket, endpoint, region, object prefix and public download URLs in
`config/packages/config.rb` under `Package::Config::S3`. The access key and
secret key are read from Rails credentials as `s3_access_key_id` and
`s3_secret_access_key`.

GitHub workflow files are installed into the consuming repository because GitHub
only detects workflows under `.github/workflows/`. The workflow source templates
remain packaged inside `sloop-pack`.

## Development

Run the test suite with:

```bash
bundle exec rspec
```
