# frozen_string_literal: true

module Package
  class Finder
    def initialize(directory:, pattern:)
      @directory = directory
      @pattern = pattern
    end

    def find
      package_files = Dir.glob(@directory.join(@pattern).to_s)
      package_file = package_files.max_by { |file| File.mtime(file) }
      return package_file if package_file

      abort "Build did not produce a package matching pattern #{@pattern}"
    end
  end
end
