require "fileutils"

module Sloop
  module Pack
    class Installer
      TEMPLATE_ROOT = File.expand_path("../../../templates", __dir__).freeze

      def initialize(destination = Dir.pwd)
        @destination = File.expand_path(destination)
      end

      def install
        install_file("config/packages/config.rb")
        install_tree(".github/workflows")
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
    end
  end
end
