# frozen_string_literal: true

require "sloop/pack/cleaner"

describe Sloop::Pack::Cleaner do
  let(:root) { Rails.root.join("tmp", "cleaner-app") }
  let(:cleaner) { described_class.new(root) }

  before do
    allow(cleaner).to receive(:system).with("yarn", "install").and_return(true)
  end

  def write_config
    config_directory = root.join("config/packages")
    FileUtils.mkdir_p(config_directory)
    File.write(config_directory.join("config.rb"), "icon: 'public/app.png',\nkeystore_filename: 'app.keystore',\n")
  end

  def clean_package(package)
    FileUtils.mkdir_p(root)
    File.write(root.join("package.json"), JSON.pretty_generate(package))
    cleaner.clean
    JSON.parse(File.read(root.join("package.json")))
  end

  it "removes sloop-pack files and preserves unrelated workflows" do
    config_directory = root.join("config/packages")
    workflows_directory = root.join(".github/workflows")
    FileUtils.mkdir_p(config_directory)
    FileUtils.mkdir_p(workflows_directory)
    write_config
    File.write(config_directory.join("app.keystore"), "keystore")
    File.write(config_directory.join("other-file.txt"), "generated package data")
    File.write(root.join("capacitor.config.ts"), "capacitor config")
    File.write(workflows_directory.join("build-apk.yml"), "generated workflow")
    File.write(workflows_directory.join("deploy.yml"), "user workflow")
    File.write(root.join("package.json"), "{}")
    cleaner.clean
    cleaner.clean

    expect(config_directory).not_to exist
    expect(root.join("capacitor.config.ts")).not_to exist
    expect(workflows_directory.join("build-apk.yml")).not_to exist
    expect(workflows_directory.join("deploy.yml")).to exist
  end

  it "removes default package scripts and dependencies but preserves custom settings" do
    package = {
      "name" => "my-app",
      "main" => "tmp/packages/main.js",
      "scripts" => {
        "tauri" => "tauri",
        "electron:start" => "custom electron command",
        "test" => "rspec"
      },
      "devDependencies" => { "electron" => "^39.2.7", "react" => "^19.0.0" },
      "dependencies" => { "electron" => "application dependency" }
    }

    cleaned = clean_package(package)

    expect(cleaned).to include(
      "name" => "my-app",
      "scripts" => { "electron:start" => "custom electron command", "test" => "rspec" },
      "devDependencies" => { "react" => "^19.0.0" },
      "dependencies" => { "electron" => "application dependency" }
    )
    expect(cleaned).not_to have_key("main")
  end

  it "runs yarn install when package.json exists" do
    FileUtils.mkdir_p(root)
    File.write(root.join("package.json"), "{}")

    cleaner.clean

    expect(cleaner).to have_received(:system).with("yarn", "install")
  end

  it "does not run yarn install when package.json is missing" do
    FileUtils.mkdir_p(root)

    cleaner.clean

    expect(cleaner).not_to have_received(:system)
  end

  it "removes only generated Electron build settings" do
    package = {
      "build" => {
        "directories" => { "output" => "tmp/electron", "app" => "dist" },
        "files" => ["tmp/packages/main.js", "custom.js"],
        "mac" => { "icon" => "public/app.png" },
        "win" => { "icon" => "custom-icon.ico" },
        "linux" => { "icon" => "tmp/electron-icons" }
      }
    }
    write_config

    cleaned = clean_package(package)

    expect(cleaned.fetch("build")).to eq(
      "directories" => { "app" => "dist" },
      "files" => ["custom.js"],
      "win" => { "icon" => "custom-icon.ico" }
    )
  end
end
