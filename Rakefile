require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'active_record'


RSpec::Core::RakeTask.new(:spec) do |task|
  # task.rspec_opts = ['--color', '--format']
end

namespace :db do 
  desc 'Created a table to work with'
  task :migrate do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'db/sqlite3'
    )
    ActiveRecord::Migrator.migrate(File.expand_path('../lib/api/migrations', __FILE__))
  end
end



task :default => :spec
