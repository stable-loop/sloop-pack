class Package::TauriBuilder
  include Rake::FileUtilsExt

  def initialize(platform)
    @platform = platform.to_sym
  end

  def build
    Package::TemplateRenderer.new.render(Package::RENDERED_DIRECTORY)
    prepare_project
    generate_icons
    package_file = tauri_builder.build
    Package::Copier.new.copy_to_public(package_file)
  end

  private

  def tauri_builder
    @tauri_builder ||= Package::Tauri::Builder.new(@platform)
  end

  def prepare_project
    FileUtils.mkdir_p(File.dirname(project_directory))
    FileUtils.rm_rf(project_directory)
    FileUtils.cp_r(
      Package::RENDERED_DIRECTORY.join("tauri"),
      project_directory
    )
  end

  def generate_icons
    Dir.chdir(project_directory) do
      sh "node", tauri_cli, "icon", public_icon, "--output", "icons"
    end
  end

  def public_icon = Rails.root.join(Package::Config::VALUES.fetch(:public_icon)).to_s
  def tauri_cli = Rails.root.join(Package::Config::TAURI.fetch(:tauri_cli)).to_s
  def project_directory = Rails.root.join(Package::Config::TAURI.fetch(:project_directory)).to_s
  def target_directory = Rails.root.join(Package::Config::TAURI.fetch(:target_directory))
end
