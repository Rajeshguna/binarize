require 'simplecov'
require "active_record"
require "yaml"
require "logger"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Migration.verbose = false

configs = YAML.load_file(File.dirname(__FILE__) + "/database.yml")
ActiveRecord::Base.configurations = configs

db_name = (ENV["DB"] || "sqlite").to_sym
ActiveRecord::Base.establish_connection(db_name)

load(File.dirname(__FILE__) + "/schema.rb")

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_adapter 'test_frameworks'
end

SimpleCov.start do
  puts "Coverage enabled"
  add_filter "/.rvm/"
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'
# require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'binarize'

def assert_equal_arrays(ar1, ar2)
  assert_equal(ar1.sort, ar2.sort)
end
