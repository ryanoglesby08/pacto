require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

Coveralls::RakeTask.new

if defined?(Rubocop)
  require 'rubocop/rake_task'

  Rubocop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['**/*.rb', 'Rakefile']
    # abort rake on failure
    task.fail_on_error = false
  end
else
  task :rubocop do
    puts "Rubocop disables becasue does't work on Ruby 1.8.7"
  end
end

Cucumber::Rake::Task.new(:journeys) do |t|
  t.cucumber_opts = 'features --format pretty'
end

if defined?(RSpec)
  desc 'Run unit tests'
  task :unit do
    abort unless system('rspec --option .rspec_unit')
  end

  desc 'Run integration tests'
  task :integration do
    abort unless system('rspec --option .rspec_integration')
  end

  task :default => [:unit, :integration, :journeys, :rubocop, 'coveralls:push']
end
