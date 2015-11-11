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

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "binarize"
  gem.homepage = "http://github.com/thanashyam/binarize"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "thanashyam@gmail.com"
  gem.authors = ["Thanashyam Raj"]
  # dependencies defined in Gemfile
  
  gem.add_dependency 'activerecord'
  gem.files = Dir.glob('lib/**/*.rb')
end
Jeweler::RubygemsDotOrgTasks.new

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


Rake::Task["console"].clear
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
