require "pathname"

module Package
  require Rails.root.join("config", "packages", "config.rb").to_s

  TEMPLATE_DIRECTORY = Pathname.new(File.expand_path("../templates/app/views/packages", __dir__)).freeze
  RENDERED_DIRECTORY = Rails.root.join(Config::VALUES.fetch(:rendered_directory)).freeze
  PUBLIC_ICON = Rails.root.join(Config::VALUES.fetch(:public_icon)).freeze

  EXTENSIONS = {
    deb: "deb",
    win: "exe",
    mac: "dmg",
    apk: "apk"
  }.freeze
  DOWNLOAD_PACKAGES = Config::GITHUB.fetch(:downloads).freeze
end
