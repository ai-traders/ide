require 'kitchen'
require 'rake'

# This task is here in order to make tests fast (to avoid installing chef client
# in each docker container being tested; Test-Kitchen needs chef client even
# when Bats tests framework is used; but do still use Test-Kitchen because of its
# directories structure conventions and readable .kitchen.yml; TODO: think
# of replacing Test-Kitchen here).
desc 'Create a docker container for each tests suite, run tests and destroy the container'
task :test_ide_scripts do
  loader = ::Kitchen::Loader::YAML.new(
    project_config: ENV['KITCHEN_YAML'],
    local_config: ENV['KITCHEN_LOCAL_YAML'],
    global_config: ENV['KITCHEN_GLOBAL_YAML']
  )
  kitchen_config = ::Kitchen::Config.new(
    loader: loader
  )
  kitchen_config.instances.each do |instance|
    instance.create()
    Rake.sh("kitchen exec #{instance.name} -c \"bats /tmp/bats/\"")
    instance.destroy()
  end
end

# In order to run each test suite manually and separatelly, example for 1 suite:
# ide --idefile ChefIdefile # we need ruby + docker
# cd ide_image_scripts
# chef exec bundle install
# chef exec bundle exec kitchen create default
# chef exec bundle exec kitchen exec default -c "bats /tmp/bats/"
# chef exec bundle exec kitchen destroy default
