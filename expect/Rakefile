require 'foodcritic'
require 'rake/testtask'
require 'tailor/rake_task'
require 'rubocop/rake_task'

task default: [:tailor, :rubocop, :foodcritic]

desc 'Lint Ruby code'
task :tailor do
  Tailor::RakeTask.new
end

RuboCop::RakeTask.new

FoodCritic::Rake::LintTask.new do |t|
  t.options = { fail_tags: ['any'] }
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
end
