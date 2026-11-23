# frozen_string_literal: true

require 'fileutils'

module Package
  module Capacitor
    class Builder
      include Rake::FileUtilsExt

      def initialize(platform)
        @platform = platform
      end

      def build
        ensure_android_project
        sh 'yarn capacitor:sync'
        generate_capacitor_assets
        remove_unused_flat_dir_repositories
        compile
        unsigned_apk = Package::Finder.new(
          directory: project_directory.join('app/build/outputs/apk/release'),
          pattern: '*-unsigned.apk'
        ).find
        Package::Capacitor::Signer.new.sign(unsigned_apk)
      end

      private

      def capacitor_config = Package::CONFIG.fetch(:capacitor)
      def project_directory = Rails.root.join(capacitor_config.fetch(:android_project_directory))
      def assets_directory = Rails.root.join(capacitor_config.fetch(:capacitor_assets_directory))
      def capacitor_icon = assets_directory.join('icon.png')
      def gradle_wrapper = Rails.root.join(capacitor_config.fetch(:gradle_wrapper)).to_s

      def ensure_android_project
        FileUtils.mkdir_p(Rails.root.join('tmp', 'www'))
        return if project_directory.directory?

        sh 'yarn cap add android'
      end

      def generate_capacitor_assets
        FileUtils.mkdir_p(assets_directory)
        FileUtils.cp Package::PUBLIC_ICON, capacitor_icon
        sh 'yarn capacitor:assets'
      ensure
        FileUtils.rm_f [capacitor_icon]
        if assets_directory.directory? &&
           assets_directory.children.empty?
          Dir.rmdir(assets_directory)
        end
      end

      def compile
        sh gradle_wrapper,
           '-p', project_directory.to_s, 'assembleRelease'
      end

      def remove_unused_flat_dir_repositories
        app_build_gradle = project_directory.join(
          'app', 'build.gradle'
        )
        app_contents = File.read(app_build_gradle)
        app_contents = app_contents.gsub(
          /\nrepositories \{\n    flatDir\{\n        dirs [^\n]+\n    \}\n\}\n/,
          "\n"
        )
        File.write(app_build_gradle, app_contents)

        cordova_build_gradle = project_directory.join(
          'capacitor-cordova-android-plugins', 'build.gradle'
        )
        cordova_contents = File.read(cordova_build_gradle)
        cordova_contents = cordova_contents.gsub(
          /\n    flatDir\{\n        dirs [^\n]+\n    \}/,
          ''
        )
        File.write(cordova_build_gradle, cordova_contents)
      end
    end
  end
end
