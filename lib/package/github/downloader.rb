# frozen_string_literal: true

require 'fileutils'

module Package
  module Github
    class Downloader
      include Rake::FileUtilsExt

      def initialize(platform)
        @platform = platform
      end

      def download(run_id)
        artifact = "pack-#{@platform}"
        extension = Package::EXTENSIONS.fetch(@platform).fetch(:extension)

        download_dir = Rails.root.join('tmp', "github-#{@platform}")
        FileUtils.rm_rf(download_dir)
        FileUtils.mkdir_p(download_dir)
        sh 'gh', 'run', 'download', run_id.to_s, '--name', artifact, '--dir', download_dir.to_s

        package_file = Dir[download_dir.join('**', "*.#{extension}").to_s].first
        return package_file if package_file

        abort "Downloaded artifact does not contain a .#{extension} package"
      end
    end
  end
end
