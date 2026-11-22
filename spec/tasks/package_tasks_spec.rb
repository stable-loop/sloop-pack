describe "package Rake tasks" do
  describe "electron:build:win" do
    it "renders the package templates and copies the built package to public" do
      package_file = stub_native_build(Package::Electron::Builder, :win, "exe")
      stale_file = Package::RENDERED_DIRECTORY.join("stale.txt")
      FileUtils.mkdir_p(stale_file.dirname)
      File.write(stale_file, "stale")

      invoke_package_task("electron:build:win")

      expect(rendered_files(Package::RENDERED_DIRECTORY)).to eq(expected_rendered_files)
      expect(Package::RENDERED_DIRECTORY.join("app-url.js").read)
        .to include(Package::Config::ELECTRON.fetch(:app_url))
      expect(stale_file).not_to exist
      expect(Rails.root.join("public", package_file.basename).read).to eq("built package")
    end
  end

  describe "tauri:build:deb" do
    it "copies the rendered Tauri project and the built package to their output directories" do
      package_file = stub_native_build(Package::Tauri::Builder, :deb, "deb")
      tauri_builder = Package::TauriBuilder.new(:deb)
      allow(tauri_builder).to receive(:sh)
      allow(Package::TauriBuilder).to receive(:new).with(:deb).and_return(tauri_builder)

      invoke_package_task("tauri:build:deb")

      project_directory = Rails.root.join(Package::Config::TAURI.fetch(:project_directory))
      template_directory = Package::TEMPLATE_DIRECTORY.join("tauri")
      rendered_config = JSON.parse(project_directory.join("tauri.conf.json").read)
      expect(rendered_files(project_directory)).to eq(expected_rendered_files(template_directory))
      expect(rendered_config.fetch("productName")).to eq(Package::Config::TAURI.fetch(:app_name))
      expect(Rails.root.join("public", package_file.basename).read).to eq("built package")
    end
  end

  describe "capacitor:build:apk" do
    it "renders the Capacitor configuration and copies the built APK to public" do
      package_file = stub_native_build(Package::Capacitor::Builder, :apk, "apk")

      invoke_package_task("capacitor:build:apk")

      expect(rendered_files(Package::RENDERED_DIRECTORY)).to eq(expected_rendered_files)
      expect(Package::RENDERED_DIRECTORY.join("capacitor.config.ts").read)
        .to include(Package::Config::CAPACITOR.fetch(:app_id))
      expect(Rails.root.join("public", package_file.basename).read).to eq("built package")
    end
  end

  describe "g:keystore" do
    it "creates the keystore through the configured keytool command" do
      generator = Package::Capacitor::KeyStoreGenerator.new
      keystore_path = Rails.root.join("config", "packages", Package::Config::CAPACITOR.fetch(:keystore_filename))
      allow(generator).to receive(:sh) do |*command|
        expect(command.first).to eq("keytool")
        expect(command).to include("-keystore", keystore_path.to_s)
        File.write(keystore_path, "test keystore")
      end
      allow(Package::Capacitor::KeyStoreGenerator).to receive(:new).and_return(generator)

      expect { invoke_package_task("g:keystore") }
        .to output(/Android keystore generated/).to_stdout

      expect(keystore_path.read).to eq("test keystore")
    end
  end
end
