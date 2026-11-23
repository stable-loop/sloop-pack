Gem::Specification.new do |spec|
  spec.name = "sloop-pack"
  spec.version = "0.1.0"
  spec.authors = ["Jorge Lebrijo"]
  spec.email = ["jlebrijo@gmail.com"]
  spec.summary = "Cross-platform application packaging for Rails projects"
  spec.description = "Build Electron, Tauri and Capacitor packages locally or through GitHub Actions."
  spec.homepage = "https://github.com/jlebrijo/sloop-pack"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"
  spec.files = Dir["lib/**/*", "templates/**/*", "exe/*", "README.md", "LICENSE"]
  spec.bindir = "exe"
  spec.executables = ["sloop-pack"]
  spec.require_paths = ["lib"]
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "fiddle"
  spec.add_dependency "marcel"
  spec.add_dependency "railties", ">= 7.0"
  spec.add_development_dependency "rspec", ">= 3.13"
end
