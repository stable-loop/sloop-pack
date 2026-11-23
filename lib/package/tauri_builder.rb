class Package::TauriBuilder
  include Rake::FileUtilsExt

  def initialize(platform)
    @platform = platform.to_sym
  end

  def build
    Package::TemplateRenderer.new.render(Package::RENDERED_DIRECTORY)
    prepare_project
    generate_icons
    package_file = Package::Normalizer.new.normalize(tauri_builder.build)
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

  def public_icon = Rails.root.join(Package::CONFIG.fetch(:icon)).to_s
  def tauri_config = Package::CONFIG.fetch(:tauri)
  def tauri_cli = Rails.root.join(tauri_config.fetch(:tauri_cli)).to_s
  def project_directory = Rails.root.join(tauri_config.fetch(:project_directory)).to_s
  def target_directory = Rails.root.join(tauri_config.fetch(:target_directory))
end
