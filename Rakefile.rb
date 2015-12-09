
desc 'Runs unit tests: ShellCheck'
task style: ['style:shellcheck']
desc 'Runs unit tests: Shpec'
task unit: ['unit:shpec']

# install shellcheck with (https://github.com/koalaman/shellcheck):
# 1. add to your apt source:
# deb http://archive.ubuntu.com/ubuntu/ trusty-backports restricted main universe
# 2. run: apt-get install shellcheck
namespace 'style' do
  task :shellcheck do
    Rake.sh('shellcheck ide')
  end
end


# install shpec with (https://github.com/rylnd/shpec):
# sudo sh -c "`curl -L https://raw.github.com/rylnd/shpec/master/install.sh`"
namespace 'unit' do
  task :shpec do
    Rake.sh('shpec test/shpec/ide.sh')
  end
end

namespace 'itest' do
  task :build_gitide do
    Dir.chdir('./examples/gitide/docker') do
      Rake.sh('docker build -t gitide:0.1.0 .')
    end
  end
  task :test_gitide_dryrun do
    Rake.sh('IDE_LOG=debug ./ide --idefile ./examples/gitide/Idefile --dryrun '\
      '"echo sth"')
  end
  task :test_gitide do
    Dir.chdir('./examples/gitide') do
      # changing current directory, because IDE_WORK in Idefile is set relative
      # to './examples/gitide'
      Rake.sh('IDE_LOG=debug ../../ide '\
        '"git clone git@git.ai-traders.com:edu/bash.git && ls -la bash"')
    end
  end
end
