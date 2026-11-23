require "sloop/pack/installer"

describe Sloop::Pack::Installer do
  it "uses the configured developer as the default package author name" do
    destination = Rails.root.join("tmp", "installer")
    package_json_path = destination.join("package.json")
    FileUtils.mkdir_p(destination)
    File.write(package_json_path, JSON.generate("name" => "sample-app"))

    installer = described_class.new(destination)
    allow(installer).to receive(:install_javascript_dependencies)
    installer.install

    package = JSON.parse(package_json_path.read)
    expect(package.fetch("author").fetch("name")).to eq(Package::CONFIG.fetch(:developer))
    expect(package.fetch("description")).to eq(Package::CONFIG.fetch(:description))
    expect(package.dig("build", "mac", "icon")).to eq(Package::CONFIG.fetch(:icon))
    expect(package.dig("build", "win", "icon")).to eq(Package::CONFIG.fetch(:icon))
    expect(package.dig("build", "linux", "icon")).to eq("tmp/electron-icons")
  end

  it "loads package configuration after the Rails environment when needed" do
    config = Package.send(:remove_const, :CONFIG)
    environment = Rails.root.join("tmp", "installer-app", "config", "environment.rb")
    FileUtils.mkdir_p(environment.dirname)
    File.write(environment, "")
    installer = described_class.new(environment.dirname.parent)
    allow(Sloop::Pack).to receive(:load_package) do
      Package.const_set(:CONFIG, config)
    end

    installer.send(:package_config)
    expect(Package::CONFIG).to equal(config)
    expect(Sloop::Pack).to have_received(:load_package)
  ensure
    Package.const_set(:CONFIG, config) unless Package.const_defined?(:CONFIG, false)
  end
end
