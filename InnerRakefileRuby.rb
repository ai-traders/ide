require 'gitrake'

GitRake::GitTasks.new

# Generally gitrake is used because of release:code rake task, which
# merges current branch to master and git tags it using version from Consul.
