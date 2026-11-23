# frozen_string_literal: true

module Package
  module Tauri
    class Builder
      include Rake::FileUtilsExt

      def initialize(platform)
        @platform = platform.to_sym
      end

      def build
        Bundler.with_unbundled_env do
          with_target_directory do
            sh 'node', tauri_cli,
               'build', '--config', 'tauri.conf.json', '--bundles', Package::Tauri::BUNDLES.fetch(@platform)
          end
        end
        Package::Finder.new(
          directory: target_directory.join(
            'release', 'bundle', Package::Tauri::BUNDLES.fetch(@platform)
          ),
          pattern: "*.#{Package::EXTENSIONS.fetch(@platform).fetch(:extension)}"
        ).find
      end

      private

      def tauri_config = Package::CONFIG.fetch(:tauri)
      def tauri_cli = Rails.root.join(tauri_config.fetch(:tauri_cli)).to_s
      def project_directory = Rails.root.join(tauri_config.fetch(:project_directory)).to_s
      def target_directory = Rails.root.join(tauri_config.fetch(:target_directory))

      def with_target_directory(&block)
        original_target_directory = ENV['CARGO_TARGET_DIR']
        original_path = ENV['PATH']
        ENV['CARGO_TARGET_DIR'] = target_directory.to_s
        cargo_bin = File.expand_path('~/.cargo/bin')
        ENV['PATH'] = "#{cargo_bin}:#{original_path}" if File.directory?(cargo_bin)
        Dir.chdir(project_directory, &block)
      ensure
        if original_target_directory
          ENV['CARGO_TARGET_DIR'] = original_target_directory
        else
          ENV.delete('CARGO_TARGET_DIR')
        end
        ENV['PATH'] = original_path
      end
    end
  end
end
