desc 'Runs unit tests: ShellCheck'
task style: ['style:shellcheck']
desc 'Runs unit tests: Shpec'
task unit: ['unit:shpec']

class String
  def cyan
    "\033[36m#{self}\033[0m"
  end
end


# install shellcheck with (https://github.com/koalaman/shellcheck):
# 1. add to your apt source:
# deb http://archive.ubuntu.com/ubuntu/ trusty-backports restricted main universe
# 2. run: apt-get install shellcheck
namespace 'style' do
  task :shellcheck do
    Rake.sh('shellcheck ide*')
  end
end

# install shpec with (https://github.com/rylnd/shpec):
# sudo sh -c "`curl -L https://raw.github.com/rylnd/shpec/master/install.sh`"
namespace 'unit' do
  task :shpec do
    Rake.sh("shpec shpec/*.sh")
  end
end

namespace 'itest' do
  desc 'Test install.sh; do not run on workstation'
  task :test_install do
    Rake.sh('sudo ./install.sh')
    ide_installed = `ide --version 2>&1`
    if ide_installed.include?('/usr/bin/ide version')
      puts 'success, ide is installed'
    else
      fail
    end
  end

  task :test_docker_dryrun do
    puts '----------------------------------------------------------'.cyan
    Dir.chdir('./test/docker/gitide-usage') do
      # with command
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide --dryrun echo sth')
      # no command
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide --dryrun')
    end
  end
  task :test_docker do
    puts '----------------------------------------------------------'.cyan
    if File.directory?('./test/docker/gitide-usage/work/bash')
      FileUtils.rm_r('./test/docker/gitide-usage/work/bash')
    end
    Dir.chdir('./test/docker/gitide-usage') do
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide '\
        '"git clone git@git.ai-traders.com:edu/bash.git && ls -la bash && pwd"')
    end
  end
  desc 'Test that IDE preserves not 0 exit status'
  task :test_docker_fail do
    puts '----------------------------------------------------------'.cyan
    rescued = false
    begin
    Dir.chdir('./test/docker/gitide-usage') do
      # exit with some weird exit status
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide --force_not_interactive '\
        '"echo abc && exit 164"')
    end
    rescue
      rescued = true
    end
    if rescued
      puts 'Succesfully rescued'
    else
      fail 'This should fail, but did not!'
    end
  end

  task :test_docker_compose_dryrun do
    puts '----------------------------------------------------------'.cyan
    Dir.chdir('./test/docker-compose/default') do
      # with command
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide --dryrun echo sth')
      # no command
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide --dryrun')
    end
  end
  task :test_docker_compose do
    puts '----------------------------------------------------------'.cyan
    if File.directory?('./test/docker-compose/default/work/bash')
      FileUtils.rm_r('./test/docker-compose/default/work/bash')
    end
    Dir.chdir('./test/docker-compose/default') do
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide '\
        '"git clone git@git.ai-traders.com:edu/bash.git && ls -la bash && pwd"')
    end
  end
  desc 'Test that IDE preserves not 0 exit status'
  task :test_docker_compose_fail do
    puts '----------------------------------------------------------'.cyan
    rescued = false
    begin
    Dir.chdir('./test/docker-compose/default') do
      # exit with some weird exit status
      Rake.sh('IDE_LOG_LEVEL=debug ../../../ide --force_not_interactive '\
        '"echo abc && exit 164"')
    end
    rescue
      rescued = true
    end
    if rescued
      puts 'Succesfully rescued'
    else
      fail 'This should fail, but did not!'
    end
  end
end

# mapped tasks for Go Server, no desc
namespace 'go' do
  namespace 'style' do
    task :shellcheck do
      Rake::Task['style:shellcheck'].invoke
    end
  end
  namespace 'unit' do
    task :shpec do
      Rake::Task['unit:shpec'].invoke
    end
  end
  namespace 'itest' do
    task :test_image do
      Rake::Task['itest:test_docker_dryrun'].invoke
      Rake::Task['itest:test_docker'].invoke
      Rake::Task['itest:test_docker_compose_dryrun'].invoke
      Rake::Task['itest:test_docker_compose'].invoke
    end
    task :test_install do
      Rake::Task['itest:test_install'].invoke
    end
  end
end
