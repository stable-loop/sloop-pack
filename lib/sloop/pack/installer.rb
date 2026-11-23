require "fileutils"
require "json"

module Sloop
  module Pack
    class Installer
      TEMPLATE_ROOT = File.expand_path("../../../templates", __dir__).freeze

      def initialize(destination = Dir.pwd)
        @destination = File.expand_path(destination)
      end

      def install
        install_file("config/packages/config.rb")
        install_file("capacitor.config.ts")
        install_tree(".github/workflows")
        install_javascript_dependencies if update_package_json
      end

      private

      def install_tree(relative_directory)
        source_directory = File.join(TEMPLATE_ROOT, relative_directory)
        Dir[File.join(source_directory, "**", "*")].each do |source|
          next unless File.file?(source)

          install_file(source.delete_prefix("#{TEMPLATE_ROOT}/"))
        end
      end

      def install_file(relative_path)
        destination = File.join(@destination, relative_path)
        if File.exist?(destination)
          puts "Skipping existing #{relative_path}"
          return
        end

        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(File.join(TEMPLATE_ROOT, relative_path), destination)
        puts "Created #{relative_path}"
      end

      def update_package_json
        path = File.join(@destination, "package.json")
        unless File.file?(path)
          puts "Skipping package.json (file does not exist)"
          return false
        end

        package = JSON.parse(File.read(path))
        package["name"] ||= File.basename(@destination).downcase.gsub(/[^a-z0-9._-]+/, "-")
        package["version"] ||= "1.0.0"
        package["description"] ||= Package::CONFIG.fetch(:description)
        package["author"] = default_author(package)
        package["main"] ||= "tmp/packages/main.js"
        package["scripts"] ||= {}
        package["scripts"].merge!(
          "tauri" => "tauri",
          "electron:start" => "electron .",
          "electron:build:deb" => "electron-builder --linux deb --publish never",
          "electron:build:win" => "electron-builder --win nsis --publish never",
          "electron:build:mac" => "electron-builder --mac dmg --publish never",
          "capacitor:sync" => "cap sync android",
          "capacitor:assets" => "capacitor-assets generate --android --androidProject tmp/android --iconBackgroundColor '#ffffff' --iconBackgroundColorDark '#111111'"
        ) { |_key, existing, _default| existing }
        package["devDependencies"] ||= {}
        package["devDependencies"].merge!(
          "@capacitor/android" => "^8.6.2",
          "@capacitor/assets" => "^4.0.0",
          "@capacitor/cli" => "^8.6.2",
          "@capacitor/core" => "^8.6.2",
          "@tauri-apps/cli" => "^2.12.6",
          "electron" => "^39.2.7",
          "electron-builder" => "^26.0.12",
          "typescript" => "^5.9.3"
        ) { |_key, existing, _default| existing }
        package["build"] ||= {}
        package["build"]["directories"] ||= { "output" => "tmp/electron" }
        package["build"]["files"] ||= [
          "tmp/packages/main.js",
          "tmp/packages/app-url.js",
          "package.json"
        ]
        package["build"]["mac"] ||= {}
        package["build"]["mac"]["icon"] ||= Package::CONFIG.fetch(:icon)
        package["build"]["win"] ||= {}
        package["build"]["win"]["icon"] ||= Package::CONFIG.fetch(:icon)
        package["build"]["linux"] ||= {}
        package["build"]["linux"]["icon"] ||= "tmp/electron-icons"

        File.write(path, "#{JSON.pretty_generate(package)}\n")
        puts "Updated package.json"
        true
      rescue JSON::ParserError => error
        abort "Could not parse package.json: #{error.message}"
      end

      def install_javascript_dependencies
        puts "Installing JavaScript dependencies with yarn..."
        success = Dir.chdir(@destination) { system("yarn", "install") }
        abort "Could not install JavaScript dependencies with yarn" unless success
      end

      def default_author(package)
        author = package["author"]
        if author.is_a?(Hash)
          author["name"] ||= Package::CONFIG.fetch(:developer)
          author["email"] ||= Package::CONFIG.fetch(:email)
          return author
        end
        return author unless author.nil?

        {
          "name" => Package::CONFIG.fetch(:developer),
          "email" => Package::CONFIG.fetch(:email)
        }
      end
    end
  end
end
