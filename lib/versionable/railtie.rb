require "mongo_mapper"
require "rails"
require "active_model/railtie"

module Versionable
  class Railtie < Rails::Railtie

    initializer "versionable.create_indexes" do |app|
      ActiveSupport.on_load(:mongo_mapper) do
        Version.create_indexes
      end
    end

  end
end

