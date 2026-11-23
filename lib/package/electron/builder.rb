class Package::Electron::Builder
  include Rake::FileUtilsExt

  def initialize(platform)
    @platform = platform
  end

  def build
    build = -> { sh "yarn electron:build:#{@platform}" }
    Bundler.with_unbundled_env(&build)

    Package::Finder.new(
      directory: Rails.root.join("tmp/electron"),
      pattern: "*.#{Package::EXTENSIONS.fetch(@platform).fetch(:extension)}"
    ).find
  end
end
