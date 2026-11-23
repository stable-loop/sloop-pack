# frozen_string_literal: true

require 'pathname'
require 'uri'

module Package
  require Rails.root.join('config', 'packages', 'config.rb').to_s

  TEMPLATE_DIRECTORY = Pathname.new(File.expand_path('../templates/app/views/packages', __dir__)).freeze
  RENDERED_DIRECTORY = Rails.root.join(CONFIG.fetch(:rendered_directory)).freeze
  PUBLIC_ICON = Rails.root.join(CONFIG.fetch(:icon)).freeze

  EXTENSIONS = {
    apk: { extension: 'apk', download_platform: :android, icon: 'android' }.freeze,
    win: { extension: 'exe', download_platform: :windows, icon: 'windows' }.freeze,
    mac: { extension: 'dmg', download_platform: :macos, icon: 'apple' }.freeze,
    deb: { extension: 'deb', download_platform: :linux, icon: 'ubuntu' }.freeze
  }.freeze

  def self.downloads
    s3_config = CONFIG.fetch(:s3)
    base_url = "#{s3_config.fetch(:endpoint).sub('://', "://#{s3_config.fetch(:bucket)}.")}/"

    EXTENSIONS.map do |_builder_platform, format|
      filename = "#{CONFIG.fetch(:tag)}.#{format.fetch(:extension)}"
      key = "#{s3_config.fetch(:prefix)}#{filename}"
      {
        platform: format.fetch(:download_platform),
        icon: format.fetch(:icon),
        filename: filename,
        url: "#{base_url}#{URI::DEFAULT_PARSER.escape(key)}"
      }.freeze
    end.freeze
  end

  DOWNLOAD_PACKAGES = Package.downloads
end
