require "fileutils"

class Package::Capacitor::Signer
  include Rake::FileUtilsExt

  def sign(package_file)
    validate_configuration

    output_dir = Rails.root.join("tmp", "capacitor")
    FileUtils.rm_rf(output_dir)
    FileUtils.mkdir_p(output_dir)
    aligned_file = output_dir.join("#{key_alias}-aligned.apk")
    signed_file = output_dir.join("#{key_alias}.apk")

    sh "zipalign", "-f", "4", package_file, aligned_file.to_s
    with_password_files(output_dir) do |keystore_password_file, key_password_file|
      sh "apksigner", "sign",
        "--ks", keystore_path,
        "--ks-pass", "file:#{keystore_password_file}",
        "--key-pass", "file:#{key_password_file}",
        "--ks-key-alias", key_alias,
        "--out", signed_file.to_s,
        aligned_file.to_s
      sh "apksigner", "verify", signed_file.to_s
    end

    signed_file.to_s
  end

  private

  def validate_configuration
    abort "Android keystore does not exist: #{keystore_path}" unless File.file?(keystore_path)
    abort "android_keystore_password credential is required" if keystore_password.empty?
    abort "android_key_alias credential is required" if key_alias.empty?
    abort "android_key_password credential is required" if key_password.empty?
  end

  def keystore_path = Rails.root.join("config", "packages", keystore_filename).to_s
  def capacitor_config = Package::CONFIG.fetch(:capacitor)
  def key_alias = capacitor_config.fetch(:keystore_key_alias).to_s
  def keystore_password = capacitor_config.fetch(:keystore_password).to_s
  def key_password = capacitor_config.fetch(:keystore_key_password).to_s
  def keystore_filename = capacitor_config.fetch(:keystore_filename)

  def with_password_files(directory)
    keystore_password_file = directory.join("keystore-password")
    key_password_file = directory.join("key-password")
    File.write(keystore_password_file, keystore_password)
    File.write(key_password_file, key_password)
    FileUtils.chmod(0o600, [ keystore_password_file, key_password_file ])
    yield keystore_password_file, key_password_file
  ensure
    FileUtils.rm_f([ keystore_password_file, key_password_file ])
  end
end
