require 'gitrake'

GitRake::GitTasks.new

# Generally gitrake is used because of release:code rake task, which
# merges current branch to master and git tags it using version from Consul.

namespace 'release' do
  # Can be ran many times, always has the same result.
  desc 'Bump version in current branch and commit and push'
  task :prerelease do
    version = OVersion.get_version(
      backend: 'consul', project_name: 'ide',
      consul_url: 'http://consul.service.mosk.consul.ai-traders.com:8500')
    version_file = "#{File.dirname(__FILE__)}/ide_version"
    File.write(version_file, "version=\"#{version}\"")
    Rake.sh("git add #{version_file}")
    Rake.sh("git commit -m \"bump to #{version}\"")
    Rake.sh('git push')
  end

  task :code => :prerelease
end
