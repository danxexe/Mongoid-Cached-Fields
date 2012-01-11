require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'factory_girl'

require 'bson'

require 'pry' # debugging

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'mongoid-cached-fields'

# $log = StringIO.new
# $logger = Logger.new($log, :debug)
$logger = Logger.new(STDOUT, :debug)


# Test database
Mongoid.configure do |config|
  config.master = Mongo::Connection.new(nil, nil, :logger => $logger).db("mongoid_cached_fields_test")
end


# Query counter

$log_count = {} # Beware, evil global

def log_count
  $log_count
end

module Mongo
  module Logging

    alias_method :log_operation_without_count, :log_operation
    def log_operation(name, payload)
      log_operation_without_count(name, payload)

      $log_count[name] ||= 0
      $log_count[name] += 1
    end

  end
end


require 'database_cleaner'
DatabaseCleaner.clean

require 'models/player'
require 'models/referee'
require 'models/match'
require 'factories'

class Test::Unit::TestCase
end
