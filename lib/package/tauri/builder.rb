# frozen_string_literal: true

module Package
  module Tauri
    class Builder
      include Rake::FileUtilsExt

      def initialize(platform)
        @platform = platform.to_sym
      end

      def build
        Bundler.with_unbundled_env { with_target_directory { build_tauri } }
        find_package
      end

      private

      def tauri_config = Package::CONFIG.fetch(:tauri)
      def tauri_cli = Rails.root.join(tauri_config.fetch(:tauri_cli)).to_s
      def project_directory = Rails.root.join(tauri_config.fetch(:project_directory)).to_s
      def target_directory = Rails.root.join(tauri_config.fetch(:target_directory))

      def build_tauri
        sh "node", tauri_cli,
           "build", "--config", "tauri.conf.json", "--bundles", Package::Tauri::BUNDLES.fetch(@platform)
      end

      def find_package
        bundle_directory = target_directory.join("release", "bundle", Package::Tauri::BUNDLES.fetch(@platform))
        extension = Package::EXTENSIONS.fetch(@platform).fetch(:extension)
        Package::Finder.new(directory: bundle_directory, pattern: "*.#{extension}").find
      end

      def with_target_directory(&block)
        original_environment = { "CARGO_TARGET_DIR" => ENV["CARGO_TARGET_DIR"], "PATH" => ENV["PATH"] }
        ENV["CARGO_TARGET_DIR"] = target_directory.to_s
        add_cargo_to_path
        Dir.chdir(project_directory, &block)
      ensure
        original_environment.each { |key, value| ENV[key] = value }
      end

      def add_cargo_to_path
        cargo_bin = File.expand_path("~/.cargo/bin")
        ENV["PATH"] = "#{cargo_bin}:#{ENV['PATH']}" if File.directory?(cargo_bin)
      end
    end
  end
end
