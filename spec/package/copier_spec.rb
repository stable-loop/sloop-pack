# frozen_string_literal: true

describe Package::Copier do
  describe "#copy_to_s3" do
    it "uploads using the S3 settings from package config" do
      s3_config = Package::CONFIG.fetch(:s3)
      package_file = Rails.root.join("tmp", "repebox.apk")
      FileUtils.mkdir_p(package_file.dirname)
      File.write(package_file, "package")
      client = instance_spy(Aws::S3::Client)
      client_options = {
        access_key_id: s3_config.fetch(:access_key_id),
        secret_access_key: s3_config.fetch(:secret_access_key),
        region: s3_config.fetch(:region),
        endpoint: s3_config.fetch(:endpoint),
        force_path_style: true
      }
      object_options = {
        bucket: s3_config.fetch(:bucket),
        key: "#{s3_config.fetch(:prefix)}#{package_file.basename}",
        acl: "public-read"
      }

      allow(Aws::S3::Client).to receive(:new).with(client_options).and_return(client)
      allow(client).to receive(:put_object)

      public_base_url = s3_config.fetch(:endpoint).sub("://", "://#{s3_config.fetch(:bucket)}.")
      expected_url = "#{public_base_url}/#{URI::DEFAULT_PARSER.escape("#{s3_config.fetch(:prefix)}#{package_file.basename}")}"
      returned_url = described_class.new.copy_to_s3(package_file)

      expect(Aws::S3::Client).to have_received(:new).with(client_options)
      expect(client).to have_received(:put_object).with(hash_including(object_options))
      expect(returned_url).to eq(expected_url)
    end
  end
end
