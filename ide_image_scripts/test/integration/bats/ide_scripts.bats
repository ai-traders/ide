load '/bats-support/load.bash'
load '/bats-assert/load.bash'

# Install the ide scripts now, they are in Docker build context
# thanks to KitchenDockerfile. (Nothing is done in Test-Kitchen
# converge phaze).
@test "ide image scripts can be installed" {
  run /tmp/ide_image_scripts_src/install.sh
  assert_equal "$status" 0
}

# all the ide scripts are set -- NOT only default scripts in this tests suite
@test "/usr/bin/entrypoint.sh exists and is a file" {
  run test -f /usr/bin/entrypoint.sh
  assert_equal "$status" 0
}
@test "/usr/bin/entrypoint.sh is owned by root" {
  run stat -c %U /usr/bin/entrypoint.sh
  assert_equal "$status" 0
  assert_equal "$output" "root"
}
@test "/usr/bin/entrypoint.sh is executable" {
  # we don't care about all the permissions, but we care that this file
  # has execute permission for the user running the test
  run test -x /usr/bin/entrypoint.sh
  assert_equal "$status" 0
}
@test "/etc/ide.d exists and is a directory" {
  run test -d /etc/ide.d
  assert_equal "$status" 0
}
@test "/etc/ide.d is owned by root" {
  run stat -c %U /etc/ide.d
  assert_equal "$status" 0
  assert_equal "$output" "root"
}
@test "/etc/ide.d/scripts exists and is a directory" {
  run test -d /etc/ide.d/scripts
  assert_equal "$status" 0
}
@test "/etc/ide.d/variables exists and is a directory" {
  run test -d /etc/ide.d/variables
  assert_equal "$status" 0
}
@test "/etc/ide.d/scripts/50-ide-fix-uid-gid.sh exists and is a file" {
  run test -f /etc/ide.d/scripts/50-ide-fix-uid-gid.sh
  assert_equal "$status" 0
}
@test "/etc/ide.d/scripts/50-ide-fix-uid-gid.sh is owned by root" {
  run stat -c %U /etc/ide.d/scripts/50-ide-fix-uid-gid.sh
  assert_equal "$status" 0
  assert_equal "$output" "root"
}
@test "/etc/ide.d/scripts/50-ide-fix-uid-gid.sh is executable" {
  run test -x /etc/ide.d/scripts/50-ide-fix-uid-gid.sh
  assert_equal "$status" 0
}
@test "/etc/ide.d/scripts/30-not-executable-file.sh is NOT executable" {
  run test -x /etc/ide.d/scripts/30-not-executable-file.sh
  assert_equal "$status" 1
}

# All the ide scripts can be executed without error and many times.
# Do not run /etc/ide.d/scripts/* on their own here,
# because it needs variables which are sourced by /usr/bin/entrypoint.sh.
@test "/usr/bin/entrypoint.sh returns 0" {
  run /usr/bin/entrypoint.sh whoami 2>&1
  echo "output: ${output}"
  # do not test which line returns those strings, sometimes there is
  # additional line: "usermod: no changes"
  assert_line --partial "ide init finished"
  assert_line --partial "Running a script which user forgot to make executable"
  assert_equal "$status" 0
  assert_line "ide"
}

@test "entrypoint made /etc/ide.d/scripts/29-not-executable-file.sh executable" {
  run test -x /etc/ide.d/scripts/29-not-executable-file.sh
  assert_equal "$status" 0

  # make it not executable again, so that tests can be run many times
  chmod 644 /etc/ide.d/scripts/29-not-executable-file.sh
}

# This must run after entrypoint.sh, because at first 30-copy-ssh-configs.sh
# may be owned by some uid:gid which does not exist in current env (ideide)
# but exists on host (on go-agent) and that uid:gid is not 1000:1000.
# Custom configuration file
@test "/etc/ide.d/scripts/30-copy-ssh-configs.sh exists and is a file" {
  run test -f /etc/ide.d/scripts/30-copy-ssh-configs.sh
  assert_equal "$status" 0
}
@test "/etc/ide.d/scripts/30-copy-ssh-configs.sh is owned by ide" {
  run stat -c %U /etc/ide.d/scripts/30-copy-ssh-configs.sh
  assert_equal "$status" 0
  assert_equal "$output" "ide"
}
@test "/etc/ide.d/scripts/30-copy-ssh-configs.sh is executable" {
  run test -x /etc/ide.d/scripts/30-copy-ssh-configs.sh
  assert_equal "$status" 0
}

# secret provided thanks to the custom configuration file
@test "/home/ide/.ssh/id_rsa exists and is a file" {
  run test -f /home/ide/.ssh/id_rsa
  assert_equal "$status" 0
}
@test "/home/ide/.ssh/id_rsa is owned by ide user" {
  run stat -c %U /home/ide/.ssh/id_rsa
  assert_equal "$status" 0
  assert_equal "$output" "ide"
}
