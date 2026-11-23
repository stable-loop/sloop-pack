require "pathname"
require "uri"

module Package
  require Rails.root.join("config", "packages", "config.rb").to_s

  TEMPLATE_DIRECTORY = Pathname.new(File.expand_path("../templates/app/views/packages", __dir__)).freeze
  RENDERED_DIRECTORY = Rails.root.join(Config::VALUES.fetch(:rendered_directory)).freeze
  PUBLIC_ICON = Rails.root.join(Config::VALUES.fetch(:icon)).freeze

  EXTENSIONS = {
    deb: "deb",
    win: "exe",
    mac: "dmg",
    apk: "apk"
  }.freeze

  def self.downloads
    formats = {
      android: { icon: "android", extension: :apk },
      windows: { icon: "windows", extension: :win },
      macos: { icon: "apple", extension: :mac },
      linux: { icon: "ubuntu", extension: :deb }
    }
    s3_config = Config::S3
    base_url = "#{s3_config.fetch(:endpoint).sub("://", "://#{s3_config.fetch(:bucket)}.")}/"

    formats.map do |platform, format|
      filename = "#{Config::VALUES.fetch(:tag)}.#{EXTENSIONS.fetch(format.fetch(:extension))}"
      key = "#{s3_config.fetch(:prefix)}#{filename}"
      {
        platform: platform,
        icon: format.fetch(:icon),
        filename: filename,
        url: "#{base_url}#{URI::DEFAULT_PARSER.escape(key)}"
      }.freeze
    end.freeze
  end

  DOWNLOAD_PACKAGES = Package.downloads
end
