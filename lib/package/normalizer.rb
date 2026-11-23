require "fileutils"

class Package::Normalizer
  def normalize(package_file)
    extension = File.extname(package_file)
    normalized_file = File.join(
      File.dirname(package_file),
      "#{Package::CONFIG.fetch(:tag)}#{extension}"
    )
    FileUtils.mv(package_file, normalized_file)
    normalized_file
  end
end
