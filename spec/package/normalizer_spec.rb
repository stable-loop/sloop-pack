describe Package::Normalizer do
  it "does not move the package when it already has the normalized filename" do
    package_file = Rails.root.join("tmp", "capacitor", "#{Package::CONFIG.fetch(:tag)}.apk")
    FileUtils.mkdir_p(package_file.dirname)
    File.write(package_file, "built package")

    normalized_file = described_class.new.normalize(package_file.to_s)

    expect(normalized_file).to eq(package_file.to_s)
    expect(package_file.read).to eq("built package")
  end
end
