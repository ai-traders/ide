# only those tasks need additional ruby dependencies (gems),
# bundler must be installed
rule(/.*repocritic|.*release:code|.*validate_repo/) do |task|
  ENV['BUNDLE_GEMFILE'] = File.expand_path("#{File.dirname(__FILE__)}/Gemfile")
  unless ENV['SKIP_ALL_DEPENDENCIES'] || ENV['SKIP_RUBY_DEPENDENCIES']
    puts "running bundle install for rake task: #{task.name}"
    sh 'bundle install'
  end
  inner_rakefile = File.expand_path(
    "#{File.dirname(__FILE__)}/InnerRakefile.rb")
  sh "bundle exec rake #{task.name} -f #{inner_rakefile}"
end

# any other rake task should be run without bundler, because no ruby dependencies
# are needed
rule(//) do |task|
  inner_rakefile = File.expand_path(
    "#{File.dirname(__FILE__)}/InnerRakefile.rb")
  sh "rake #{task.name} -f #{inner_rakefile}"
end
