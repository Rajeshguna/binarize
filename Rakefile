# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "binarize #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


desc "Open My own irb session preloaded with this library"
task :console do
  require "active_record"
  require "yaml"
  require "logger"
  require "binarize"

  configs = YAML.load_file(File.dirname(__FILE__) + "/test/database.yml")
  ActiveRecord::Base.configurations = configs

  db_name = (ENV["DB"] || "sqlite").to_sym
  ActiveRecord::Base.establish_connection(db_name)

  load(File.dirname(__FILE__) + "/test/schema.rb")

  require 'irb'
  ARGV.clear
  IRB.start
end
