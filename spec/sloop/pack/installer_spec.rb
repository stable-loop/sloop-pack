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
end
