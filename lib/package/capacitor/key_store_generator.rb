require "fileutils"

class Package::Capacitor::KeyStoreGenerator
  include Rake::FileUtilsExt

  def generate
    abort "Android keystore already exists: #{keystore_path}" if File.exist?(keystore_path)

    FileUtils.mkdir_p(keystore_directory)
    validate_configuration

    sh "keytool",
      "-genkeypair",
      "-v",
      "-keystore", keystore_path,
      "-storetype", "JKS",
      "-storepass", keystore_password,
      "-keypass", key_password,
      "-alias", key_alias,
      "-keyalg", "RSA",
      "-keysize", "4096",
      "-validity", validity_days,
      "-dname", "CN=Repebox, OU=Repebox, O=, L=, ST=, C=ES"

    puts
    puts "Android keystore generated: #{keystore_path}"
    puts "android_key_alias: #{key_alias}"
    puts "android_keystore_password: #{keystore_password}"
    puts "android_key_password: #{key_password}"
    puts
    puts "Store these values in Rails credentials and back up the keystore securely."
    puts "Add secret to Github for Actions:"
    puts "> gh secret set ANDROID_KEYSTORE_BASE64 < <(base64 -w 0 config/packages/repebox-release.keystore)"
  end

  private

  def validate_configuration
    abort "android_keystore_password credential is required" if keystore_password.empty?
    abort "android_key_password credential is required" if key_password.empty?
  end

  def capacitor_config = Package::CONFIG.fetch(:capacitor)
  def keystore_directory = Rails.root.join("config", "packages")
  def keystore_password = capacitor_config.fetch(:keystore_password).to_s
  def key_password = capacitor_config.fetch(:keystore_key_password).to_s
  def keystore_path = keystore_directory.join(keystore_filename).to_s
  def keystore_filename = capacitor_config.fetch(:keystore_filename)
  def key_alias = capacitor_config.fetch(:keystore_key_alias)
  def validity_days = capacitor_config.fetch(:keystore_validity_days)
end
