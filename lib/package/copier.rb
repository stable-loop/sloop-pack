# frozen_string_literal: true

require 'fileutils'
require 'aws-sdk-s3'
require 'marcel'
require 'uri'

module Package
  class Copier
    def copy_to_public(package_file)
      public_dir = Rails.root.join('public')
      FileUtils.mkdir_p(public_dir)
      destination = public_dir.join(File.basename(package_file))
      FileUtils.cp(package_file, destination)
      puts "Package copied to #{destination}"
    end

    def copy_to_s3(package_file)
      filename = File.basename(package_file)
      key = "#{s3_config.fetch(:prefix)}#{filename}"
      upload_package(package_file, key)
      url = public_url(key)
      puts "Package uploaded to S3: #{url}"
      url
    end

    private

    def s3_config = Package::CONFIG.fetch(:s3)

    def upload_package(package_file, key)
      File.open(package_file, 'rb') do |file|
        s3_client.put_object(
          bucket: s3_config.fetch(:bucket),
          key: key,
          body: file,
          content_type: Marcel::MimeType.for(package_file),
          acl: 'public-read'
        )
      end
    end

    def s3_client
      Aws::S3::Client.new(
        access_key_id: s3_config.fetch(:access_key_id),
        secret_access_key: s3_config.fetch(:secret_access_key),
        region: s3_config.fetch(:region),
        endpoint: s3_config.fetch(:endpoint),
        force_path_style: true
      )
    end

    def public_url(key)
      "#{s3_config.fetch(:endpoint).sub('://', "://#{s3_config.fetch(:bucket)}.")}/#{URI::DEFAULT_PARSER.escape(key)}"
    end
  end
end
