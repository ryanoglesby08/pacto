require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'pacto/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

Coveralls::RakeTask.new

if defined? Rubycop
  require 'rubocop/rake_task'
  Rubocop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['**/*.rb', 'Rakefile']
    # abort rake on failure
    task.fail_on_error = false
  end
else
  task :rubocop do
    puts 'Rubocop could not be loaded are you on Ruby 1.8?'
  end
end

Cucumber::Rake::Task.new(:journeys) do |t|
  t.cucumber_opts = 'features --format pretty'
end

RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = 'spec/integration/**/*_spec.rb'
end

task :default => [:unit, :integration, :journeys, :rubocop, 'coveralls:push']
