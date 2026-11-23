# frozen_string_literal: true

module Package
  class GithubBuilder
    def initialize(platform)
      @platform = platform.to_sym
    end

    def build
      run_id = github_runner.run
      puts "GitHub Actions: downloading pack-#{@platform}..."
      package_file = github_downloader.download(run_id)
      Package::Copier.new.copy_to_s3(package_file)
    end

    private

    def github_downloader
      @github_downloader ||= Package::Github::Downloader.new(@platform)
    end

    def github_runner
      @github_runner ||= Package::Github::Runner.new(@platform)
    end
  end
end
