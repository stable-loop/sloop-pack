require "sloop/pack/version"
require "sloop/pack/railtie" if defined?(Rails::Railtie)

module Sloop
  module Pack
    def self.load_package
      require "package"
      Dir[File.expand_path("package/**/*.rb", __dir__.sub(%r{/sloop$}, ""))].sort.each { |file| require file }
    end
  end
end
