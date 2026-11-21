require "rails/railtie"

module Sloop
  module Pack
    class Railtie < Rails::Railtie
      initializer "sloop_pack.load", after: :load_config_initializers do
        Sloop::Pack.load_package
      end

      rake_tasks do
        load File.expand_path("../../tasks/packages.rake", __dir__)
      end
    end
  end
end
