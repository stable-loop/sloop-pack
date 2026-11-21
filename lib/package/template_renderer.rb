require "erb"
require "fileutils"
require "pathname"
require Rails.root.join("config", "packages", "config.rb").to_s

class Package::TemplateRenderer
  def render(target_directory)
    FileUtils.rm_rf(target_directory)

    Dir.glob(Package::TEMPLATE_DIRECTORY.join("**", "*.erb")).each do |template_path|
      relative_path = Pathname(template_path).relative_path_from(Package::TEMPLATE_DIRECTORY)
      output_path = Pathname(target_directory).join(relative_path.to_s.delete_suffix(".erb"))
      FileUtils.mkdir_p(output_path.dirname)
      File.write(output_path, render_template(template_path))
    end

    target_directory
  end

  private

  def render_template(template_path)
    ERB.new(File.read(template_path)).result_with_hash(config: Package::Config::VALUES)
  end
end
