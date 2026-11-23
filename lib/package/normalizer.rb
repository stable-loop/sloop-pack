require "fileutils"

class Package::Normalizer
  def normalize(package_file)
    extension = File.extname(package_file)
    normalized_file = File.join(
      File.dirname(package_file),
      "#{Package::CONFIG.fetch(:tag)}#{extension}"
    )
    return normalized_file if File.expand_path(package_file) == File.expand_path(normalized_file)

    FileUtils.mv(package_file, normalized_file)
    normalized_file
  end
end
