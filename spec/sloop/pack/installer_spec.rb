# frozen_string_literal: true

require "sloop/pack/installer"

describe Sloop::Pack::Installer do
  let(:destination) { Rails.root.join("tmp", "sample-app") }
  let(:package_json_path) { destination.join("package.json") }
  let(:installer) { described_class.new(destination) }

  before do
    FileUtils.mkdir_p(destination)
    File.write(package_json_path, JSON.generate("name" => "app", "productName" => "app"))
    allow(installer).to receive(:install_javascript_dependencies)
  end

  def install_and_read_package
    installer.install
    JSON.parse(package_json_path.read)
  end

  it "uses the app directory as the package name" do
    expect(install_and_read_package.fetch("name")).to eq("sample-app")
  end

  it "uses configured package metadata" do
    package = install_and_read_package

    expect(package).to include(
      "author" => { "name" => Package::CONFIG.fetch(:developer), "email" => Package::CONFIG.fetch(:email) },
      "description" => Package::CONFIG.fetch(:description)
    )
  end

  it "sets configured icons for Electron builds" do
    package = install_and_read_package

    expect(package.dig("build", "mac", "icon")).to eq(Package::CONFIG.fetch(:icon))
    expect(package.dig("build", "win", "icon")).to eq(Package::CONFIG.fetch(:icon))
    expect(package.dig("build", "linux", "icon")).to eq("tmp/electron-icons")
  end

  it "uses the configured keystore filename in the GitHub workflow" do
    install_and_read_package
    workflow = destination.join(".github/workflows/build-apk.yml").read

    expect(workflow).to include("config/packages/#{Package::CONFIG.fetch(:capacitor).fetch(:keystore_filename)}")
  end

  it "loads package configuration after the Rails environment when needed" do
    config = Package::CONFIG
    stub_const("Package", Module.new)
    environment = Rails.root.join("tmp", "installer-app", "config", "environment.rb")
    FileUtils.mkdir_p(environment.dirname)
    File.write(environment, "")
    isolated_installer = described_class.new(environment.dirname.parent)
    allow(Sloop::Pack).to receive(:load_package) do
      Package.const_set(:CONFIG, config)
    end

    isolated_installer.send(:package_config)
    expect(Package::CONFIG).to equal(config)
    expect(Sloop::Pack).to have_received(:load_package)
  end
end
