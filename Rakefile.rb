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
    Rake.sh('shellcheck ide')
    Rake.sh('shellcheck ide_functions')
  end
end

# install shpec with (https://github.com/rylnd/shpec):
# sudo sh -c "`curl -L https://raw.github.com/rylnd/shpec/master/install.sh`"
namespace 'unit' do
  task :shpec do
    Rake.sh("shpec test/unit/shpec/**/*.sh")
  end
end

namespace 'itest' do
  # this is needed to run shpec itests
  task :build_dummyide do
    FileUtils.rm_rf('test/docker-dummyide/src')
    FileUtils.cp_r("#{File.dirname(__FILE__)}/ide_image_scripts/src",
      'test/docker-dummyide/src')
    Dir.chdir('test/docker-dummyide') do
      Rake.sh('docker build -t dummyide:0.0.1 .')
    end
  end
  task :shpec do
    Rake.sh("shpec test/integration/shpec/*.sh")
  end
  task :test_image do
    Rake::Task['itest:build_dummyide'].invoke
    Rake::Task['itest:shpec'].invoke
  end

  desc 'Test install.sh; do not run on workstation'
  task :test_install do
    Rake.sh('sudo ./install.sh')
    ide_installed = `ide -c version 2>&1`
    if ide_installed.include?('/usr/bin/ide version')
      puts 'success, ide is installed'
    else
      fail
    end
  end

  desc 'Test local_install.sh; do not run on workstation'
  task :test_local_install do
    Rake.sh('sudo ./local_install.sh')
    ide_installed = `ide -c version 2>&1`
    if ide_installed.include?('/usr/bin/ide version')
      puts 'success, ide is installed'
    else
      fail
    end
  end
end
