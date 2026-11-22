require "fileutils"
require "json"
require "pathname"
require "rake"
require "rspec"
require "tmpdir"

module Rails
  class << self
    attr_accessor :root
  end
end

Rails.root = Pathname.new(Dir.mktmpdir("sloop-pack-spec"))

module Cred
  def self.[](key)
    "test-#{key}"
  end
end

config_directory = Rails.root.join("config", "packages")
FileUtils.mkdir_p(config_directory)
FileUtils.cp(
  File.expand_path("../templates/config/packages/config.rb", __dir__),
  config_directory.join("config.rb")
)

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "sloop/pack"
Sloop::Pack.load_package

module PackageTaskHelpers
  TASKS_FILE = File.expand_path("../lib/tasks/packages.rake", __dir__)

  def invoke_package_task(name)
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load TASKS_FILE
    Rake::Task[name].invoke
  end

  def stub_native_build(builder_class, platform, extension)
    package_file = Rails.root.join("tmp", "native-build", "fixture.#{extension}")
    FileUtils.mkdir_p(package_file.dirname)
    File.write(package_file, "built package")

    builder = instance_double(builder_class, build: package_file.to_s)
    allow(builder_class).to receive(:new).with(platform).and_return(builder)
    package_file
  end

  def rendered_files(directory)
    Dir.glob(directory.join("**", "*"))
      .select { |path| File.file?(path) }
      .map { |path| Pathname(path).relative_path_from(directory).to_s }
      .sort
  end

  def expected_rendered_files(template_directory = Package::TEMPLATE_DIRECTORY)
    Dir.glob(template_directory.join("**", "*.erb"))
      .map do |path|
        Pathname(path).relative_path_from(template_directory).to_s.delete_suffix(".erb")
      end
      .sort
  end
end

RSpec.configure do |config|
  config.include PackageTaskHelpers

  config.before do
    FileUtils.rm_rf(Rails.root.join("tmp"))
    FileUtils.rm_rf(Rails.root.join("public"))
    Rake.application = Rake::Application.new
  end

  config.after(:suite) do
    FileUtils.remove_entry(Rails.root.to_s) if Rails.root.directory?
  end
end
