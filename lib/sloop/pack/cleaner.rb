# frozen_string_literal: true

require "fileutils"
require "json"

module Sloop
  module Pack
    class Cleaner
      WORKFLOWS = %w[build-apk.yml build-deb.yml build-mac.yml build-win.yml].freeze
      SCRIPTS = {
        "tauri" => "tauri",
        "electron:start" => "electron .",
        "electron:build:deb" => "electron-builder --linux deb --publish never",
        "electron:build:win" => "electron-builder --win nsis --publish never",
        "electron:build:mac" => "electron-builder --mac dmg --publish never",
        "capacitor:sync" => "cap sync android",
        "capacitor:assets" => [
          "capacitor-assets generate --android --androidProject tmp/android",
          "--iconBackgroundColor '#ffffff' --iconBackgroundColorDark '#111111'"
        ].join(" ")
      }.freeze
      DEPENDENCIES = %w[
        @capacitor/android @capacitor/assets @capacitor/cli @capacitor/core
        @tauri-apps/cli electron electron-builder typescript
      ].freeze
      BUILD_FILES = %w[tmp/packages/main.js tmp/packages/app-url.js package.json].freeze

      def initialize(root = Dir.pwd)
        @root = File.expand_path(root)
      end

      def clean
        clean_package_json
        remove_workflows
        remove_generated_files
        install_javascript_dependencies
        puts "Sloop Pack files cleaned"
      end

      private

      def install_javascript_dependencies
        return unless File.file?(project_path("package.json"))

        puts "Regenerating yarn.lock with yarn..."
        success = Dir.chdir(@root) { system("yarn", "install") }
        abort "Could not regenerate yarn.lock with yarn install" unless success
      end

      def clean_package_json
        path = project_path("package.json")
        return unless File.file?(path)

        package = JSON.parse(File.read(path))
        changed = remove_generated_scripts(package)
        changed = remove_generated_dependencies(package) || changed
        changed = remove_generated_entry_point(package) || changed
        changed = remove_generated_build_config(package) || changed
        File.write(path, "#{JSON.pretty_generate(package)}\n") if changed
      rescue JSON::ParserError => e
        abort "Could not parse package.json: #{e.message}"
      end

      def remove_generated_scripts(package)
        scripts = package["scripts"]
        return false unless scripts.is_a?(Hash)

        changed = false
        SCRIPTS.each do |name, command|
          next unless scripts[name] == command

          scripts.delete(name)
          changed = true
        end
        package.delete("scripts") if changed && scripts.empty?
        changed
      end

      def remove_generated_dependencies(package)
        dependencies = package["devDependencies"]
        return false unless dependencies.is_a?(Hash)

        removed = dependencies.keys & DEPENDENCIES
        removed.each { |name| dependencies.delete(name) }
        package.delete("devDependencies") if removed.any? && dependencies.empty?
        removed.any?
      end

      def remove_generated_entry_point(package)
        return false unless package["main"] == "tmp/packages/main.js"

        package.delete("main")
        true
      end

      def remove_generated_build_config(package)
        build = package["build"]
        return false unless build.is_a?(Hash)

        changed = remove_generated_build_paths(build)
        changed = remove_generated_icons(build) || changed
        package.delete("build") if changed && build.empty?
        changed
      end

      def remove_generated_build_paths(build)
        output_changed = remove_output_directory(build)
        files_changed = remove_build_files(build)
        output_changed || files_changed
      end

      def remove_output_directory(build)
        directories = build["directories"]
        return false unless directories.is_a?(Hash) && directories["output"] == "tmp/electron"

        directories.delete("output")
        build.delete("directories") if directories.empty?
        true
      end

      def remove_build_files(build)
        files = build["files"]
        return false unless files.is_a?(Array)

        remaining = files - BUILD_FILES
        return false if remaining == files

        remaining.empty? ? build.delete("files") : build["files"] = remaining
        true
      end

      def remove_generated_icons(build)
        icon = configured_value(:icon) || "public/icon_mobile.png"
        changed = remove_platform_icon(build, "mac", icon)
        changed = remove_platform_icon(build, "win", icon) || changed
        remove_platform_icon(build, "linux", "tmp/electron-icons") || changed
      end

      def remove_platform_icon(build, platform, expected_icon)
        config = build[platform]
        return false unless config.is_a?(Hash) && expected_icon && config["icon"] == expected_icon

        config.delete("icon")
        build.delete(platform) if config.empty?
        true
      end

      def remove_workflows
        WORKFLOWS.each { |filename| remove_file(".github/workflows/#{filename}") }
      end

      def remove_generated_files
        remove_file("capacitor.config.ts")
        remove_directory("config/packages")
      end

      def configured_value(key)
        config_path = project_path("config/packages/config.rb")
        return unless File.file?(config_path)

        match = File.read(config_path).match(/^\s*#{Regexp.escape(key.to_s)}:\s*['"]([^'"]+)['"]/)
        match && match[1]
      end

      def remove_file(relative_path)
        path = project_path(relative_path)
        return unless File.file?(path)

        FileUtils.rm_f(path)
        puts "Removed #{relative_path}"
      end

      def remove_directory(relative_path)
        path = project_path(relative_path)
        return unless Dir.exist?(path)

        FileUtils.rm_rf(path)
        puts "Removed #{relative_path}"
      end

      def project_path(relative_path)
        File.join(@root, relative_path)
      end
    end
  end
end
