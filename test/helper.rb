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

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("mongoid_cached_fields_test")
end

require 'database_cleaner'
DatabaseCleaner.clean

require File.join(File.dirname(__FILE__), 'models', 'player')
require File.join(File.dirname(__FILE__), 'models', 'referee')
require File.join(File.dirname(__FILE__), 'models', 'match')
require File.join(File.dirname(__FILE__), 'factories')

class Test::Unit::TestCase
end
