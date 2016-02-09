# Do not declare those because of the error "Don't know how to build task 'style'"
# when running in ideide docker image
# Rake::Task['style'].clear
desc 'Runs unit tests: ShellCheck'
task style: ['style:shellcheck', 'style:repocritic']
desc 'Runs unit tests: Shpec'
task unit: ['unit:shpec']

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
  # if running interactively fails, try sth like:
  # docker run -ti --rm -v /home/ewa/code/ide/examples/gitide/work:/ide/work -v /home/ewa:/ide/identity:ro --env-file="/tmp/ide/environment-2016-02-08_14-49-07" --entrypoint="/bin/bash" gitide:0.1.0 -c "/bin/bash"
  desc 'do not run on workstation'
  task :test_install do
    Rake.sh('./install.sh')
    ide_installed = `ide --version 2>&1`
    if ide_installed.include?('/usr/bin/ide version')
      puts 'success, ide is installed'
    else
      fail
    end
  end

  task :build_gitide do
    version = File.read('./examples/gitide/docker/scripts/docker_image_version.txt')
      .chomp()
    Dir.chdir('./examples/gitide/docker') do
      Rake.sh("docker build -t gitide:#{version} .")
    end
  end
  task :test_gitide_dryrun do
    Dir.chdir('./examples/gitide-usage') do
      # changing current directory, because IDE_WORK in Idefile is set relative
      # to './examples/gitide-usage'

      # with command
      Rake.sh('IDE_LOG_LEVEL=debug ../../ide --dryrun echo sth')
      # no command
      Rake.sh('IDE_LOG_LEVEL=debug ../../ide --dryrun')
    end
  end
  task :test_gitide do
    if File.directory?('./examples/gitide-usage/work/bash')
      FileUtils.rm_r('./examples/gitide-usage/work/bash')
    end
    Dir.chdir('./examples/gitide-usage') do
      # changing current directory, because IDE_WORK in Idefile is set relative
      # to './examples/gitide-usage'
      Rake.sh('IDE_LOG_LEVEL=debug ../../ide '\
        '"git clone git@git.ai-traders.com:edu/bash.git && ls -la bash && pwd"')
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
    task :itest do
      Rake::Task['itest:build_gitide'].invoke
      Rake::Task['itest:test_gitide_dryrun'].invoke
      Rake::Task['itest:test_gitide'].invoke
    end
  end
end
