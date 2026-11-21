class Package::CapacitorBuilder
  def initialize(platform)
    @platform = platform.to_sym
  end

  def build
    Package::TemplateRenderer.new.render(Package::RENDERED_DIRECTORY)
    package_file = capacitor_builder.build
    Package::Copier.new.copy_to_public(package_file)
  end

  private

  def capacitor_builder
    @capacitor_builder ||= Package::Capacitor::Builder.new(@platform)
  end
end
