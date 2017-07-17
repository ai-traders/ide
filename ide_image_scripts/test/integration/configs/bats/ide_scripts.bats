load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

IDE_PATH="../ide"

# All the ide scripts are installed, but IDE entrypoint was not run.

@test "/usr/bin/entrypoint.sh file exists and is executable" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested_configs -- -c \"test -x /usr/bin/entrypoint.sh\""
  # this is printed on test failure
  echo "output: $output"
  assert_equal "$status" 0
}
@test "/etc/ide.d, /etc/ide.d/scripts, /etc/ide.d/variables drectories exist" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested_configs -- -c \"test -d /etc/ide.d && test -d /etc/ide.d/scripts && test -d /etc/ide.d/variables\""
  # this is printed on test failure
  echo "output: $output"
  assert_equal "$status" 0
}
@test "/etc/ide.d/scripts/50-ide-fix-uid-gid.sh file exists and is executable" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested_configs -- -c \"test -x /etc/ide.d/scripts/50-ide-fix-uid-gid.sh\""
  # this is printed on test failure
  echo "output: $output"
  assert_equal "$status" 0
}
@test "/etc/ide.d/scripts/29-not-executable-file.sh is NOT executable" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested_configs -- -c \"test -x /etc/ide.d/scripts/29-not-executable-file.sh\""
  # this is printed on test failure
  echo "output: $output"
  assert_equal "$status" 1
}

# Let's run the IDE entrypoint.
# (Do not run /etc/ide.d/scripts/* on their own here,
# because they need variables which are sourced by /usr/bin/entrypoint.sh).
@test "/usr/bin/entrypoint.sh returns 0" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested_configs -- -c \"/usr/bin/entrypoint.sh whoami 2>&1\""
  # this is printed on test failure
  echo "output: $output"
  assert_equal "$status" 0
  assert_line --partial "ide init finished"
  refute_output --partial "root"
  # The file /etc/ide.d/scripts/29-not-executable-file.sh was non-executable,
  # but IDE entrypoint changed it and ran that file
  assert_line --partial "Running a script which user forgot to make executable"
}
@test "/usr/bin/entrypoint.sh provides secrets and configuration" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested_configs -- -c \"/usr/bin/entrypoint.sh whoami 2>&1 && stat -c %U /home/ide/.ssh/id_rsa && cat /home/ide/.ssh/id_rsa\""
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "ide"
  # Custom file: /etc/ide.d/scripts/30-copy-ssh-configs.sh was run by IDE entrypoint
  assert_line --partial "inside id_rsa"
  refute_output --partial "root"
  assert_equal "$status" 0
}
#
# # @test "cleanup" {
# #   # make the non-executable file, non-executable again, so that tests can be run many times
# #   chmod 644 test/integration/test-files/etc_ide.d/scripts/29-not-executable-file.sh
# # }
