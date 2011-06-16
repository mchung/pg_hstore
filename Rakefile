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
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "pg_hstore"
  gem.homepage = "http://github.com/mchung/pg_hstore"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "mchung@gmail.com"
  gem.authors = ["Marc Chung"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

task :createdb do
  config = YAML.load_file("./database.yml")
  `createdb #{config[:database]} -O #{config[:username]}`
end

task :dropdb do
  config = YAML.load_file("./database.yml")
  `dropdb #{config[:database]}`
end

task :hstore_setup do
  config = YAML.load_file("./database.yml")
  `psql #{config[:database]} -f ./hstore/hstore-1.15.sql`
end