desc "Build Repebox packages"
namespace :electron do
  namespace :build do
    task deb: :environment do
      Package::ElectronBuilder.new(:deb).build
    end

    desc "Build the Repebox Electron Windows package"
    task win: :environment do
      Package::ElectronBuilder.new(:win).build
    end

    desc "Build the Repebox Electron macOS package"
    task mac: :environment do
      Package::ElectronBuilder.new(:mac).build
    end
  end
end

namespace :tauri do
  namespace :build do
    desc "Build the Repebox Tauri Debian package"
    task deb: :environment do
      Package::TauriBuilder.new(:deb).build
    end

    desc "Build the Repebox Tauri Windows package"
    task win: :environment do
      Package::TauriBuilder.new(:win).build
    end

    desc "Build the Repebox Tauri macOS package"
    task mac: :environment do
      Package::TauriBuilder.new(:mac).build
    end
  end
end

namespace :capacitor do
  namespace :build do
    desc "Build the Repebox Capacitor Android APK"
    task apk: :environment do
      Package::CapacitorBuilder.new(:apk).build
    end
  end
end

namespace :g do
  desc "Generate the Android release keystore and secure passwords"
  task keystore: :environment do
    Package::Capacitor::KeyStoreGenerator.new.generate
  end
end

namespace :package do
  desc "Upload a local package to S3 and print its public URL"
  task :upload, [ :file ] => :environment do |_, args|
    package_file = File.expand_path(args.fetch(:file), Rails.root)
    abort "Package file does not exist: #{package_file}" unless File.file?(package_file)

    Package::Copier.new.copy_to_s3(package_file)
  end
end

namespace :github do
  namespace :build do
    desc "Run the GitHub Actions Debian build and download the package"
    task deb: :environment do
      Package::GithubBuilder.new(:deb).build
    end

    desc "Run the GitHub Actions Windows build and download the package"
    task win: :environment do
      Package::GithubBuilder.new(:win).build
    end

    desc "Run the GitHub Actions macOS build and download the package"
    task mac: :environment do
      Package::GithubBuilder.new(:mac).build
    end

    desc "Run the GitHub Actions Android build and download the package"
    task apk: :environment do
      Package::GithubBuilder.new(:apk).build
    end
  end
end
