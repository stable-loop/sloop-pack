# frozen_string_literal: true

describe Package do
  describe '.downloads' do
    it 'builds download metadata from the package and S3 configuration' do
      downloads = described_class.downloads
      s3_config = Package::CONFIG.fetch(:s3)
      base_url = "#{s3_config.fetch(:endpoint).sub('://', "://#{s3_config.fetch(:bucket)}.")}/"
      expected = {
        android: %w[android apk],
        windows: %w[windows exe],
        macos: %w[apple dmg],
        linux: %w[ubuntu deb]
      }

      expect(downloads.map { |download| download.fetch(:platform) }).to eq(expected.keys)
      downloads.each do |download|
        icon, extension = expected.fetch(download.fetch(:platform))
        filename = "#{Package::CONFIG.fetch(:tag)}.#{extension}"
        key = "#{s3_config.fetch(:prefix)}#{filename}"

        expect(download).to include(
          icon: icon,
          filename: filename,
          url: "#{base_url}#{URI::DEFAULT_PARSER.escape(key)}"
        )
      end
      expect(Package::DOWNLOAD_PACKAGES).to eq(downloads)
    end
  end
end
