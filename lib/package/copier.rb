require "fileutils"
require "aws-sdk-s3"
require "uri"

class Package::Copier
  S3_BUCKET = "stableloop-public"
  S3_ENDPOINT = "https://s3.fr-par.scw.cloud"
  S3_REGION = "fr-par"
  S3_PREFIX = "repebox/"

  def copy_to_public(package_file)
    public_dir = Rails.root.join("public")
    FileUtils.mkdir_p(public_dir)
    destination = public_dir.join(File.basename(package_file))
    FileUtils.cp(package_file, destination)
    puts "Package copied to #{destination}"
  end

  def copy_to_s3(package_file)
    filename = File.basename(package_file)
    key = "#{S3_PREFIX}#{filename}"
    client = s3_client

    File.open(package_file, "rb") do |file|
      client.put_object(
        bucket: S3_BUCKET,
        key: key,
        body: file,
        content_type: Marcel::MimeType.for(package_file),
        acl: "public-read"
      )
    end

    url = public_url(key)
    puts "Package uploaded to S3: #{url}"
    url
  end

  private

  def s3_client
    Aws::S3::Client.new(
      access_key_id: Cred[:s3_access_key_id],
      secret_access_key: Cred[:s3_secret_access_key],
      region: S3_REGION,
      endpoint: S3_ENDPOINT,
      force_path_style: true
    )
  end

  def public_url(key)
    "#{S3_ENDPOINT.sub("://", "://#{S3_BUCKET}.")}/#{URI::DEFAULT_PARSER.escape(key)}"
  end
end
