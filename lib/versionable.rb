require 'differ'
require 'mongo_mapper'
require 'versionable/plugins/versionable'
require "versionable/railtie" if defined?(Rails::Railtie)

MongoMapper::Document.plugin(Versionable)

require 'versionable/sweeper'
