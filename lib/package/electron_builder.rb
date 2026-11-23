class Package::ElectronBuilder
  def initialize(platform)
    @platform = platform.to_sym
  end

  def build
    Package::TemplateRenderer.new.render(Package::RENDERED_DIRECTORY)
    Package::Electron::IconGenerator.new.generate if debian?
    package_file = Package::Normalizer.new.normalize(electron_builder.build)
    Package::Copier.new.copy_to_public(package_file)
  end

  private

  def debian? = @platform == :deb

  def electron_builder
    @electron_builder ||= Package::Electron::Builder.new(@platform)
  end
end
