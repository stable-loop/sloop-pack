require "fileutils"

class Package::Electron::IconGenerator
  include Rake::FileUtilsExt

  ICON_SIZES = %w[16 24 32 48 64 128 256 512].freeze

  def generate
    icon_dir = Rails.root.join("tmp/electron-icons")
    FileUtils.rm_rf(icon_dir)
    FileUtils.mkdir_p(icon_dir)

    ICON_SIZES.each do |size|
      sh "convert", public_icon, "-resize", "#{size}x#{size}",
         icon_dir.join("#{size}x#{size}.png").to_s
    end
  end

  def public_icon = Package::CONFIG.fetch(:icon)
end
