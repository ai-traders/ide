# Install the ide scripts now, they are in Docker build context
# thanks to KitchenDockerfile. (Nothing is done in Test-Kitchen
# converge phaze).
@test "ide image scripts can be installed" {
  run /tmp/ide_image_scripts_src/install.sh
  [ "$status" -eq 0 ]
}

# all the ide scripts are set -- only default scripts in this tests suite
@test "/usr/bin/entrypoint.sh exists and is a file" {
  run test -f /usr/bin/entrypoint.sh
  [ "$status" -eq 0 ]
}
@test "/usr/bin/entrypoint.sh is owned by root" {
  run stat -c %U /usr/bin/entrypoint.sh
  [ "$status" -eq 0 ]
  [ "$output" = "root" ]
}
@test "/usr/bin/entrypoint.sh is executable" {
  run stat -c %a /usr/bin/entrypoint.sh
  [ "$status" -eq 0 ]
  [ "$output" = "755" ]
}
@test "/etc/ide.d exists and is a directory" {
  run test -d /etc/ide.d
  [ "$status" -eq 0 ]
}
@test "/etc/ide.d is owned by root" {
  run stat -c %U /etc/ide.d
  [ "$status" -eq 0 ]
  [ "$output" = "root" ]
}
@test "/etc/ide.d/50-ide-fix-uid-gid.sh exists and is a file" {
  run test -f /etc/ide.d/50-ide-fix-uid-gid.sh
  [ "$status" -eq 0 ]
}
@test "/etc/ide.d/50-ide-fix-uid-gid.sh is owned by root" {
  run stat -c %U /etc/ide.d/50-ide-fix-uid-gid.sh
  [ "$status" -eq 0 ]
  [ "$output" = "root" ]
}
@test "/etc/ide.d/50-ide-fix-uid-gid.sh is executable" {
  run stat -c %a /etc/ide.d/50-ide-fix-uid-gid.sh
  [ "$status" -eq 0 ]
  [ "$output" = "755" ]
}
# custom configuration file
@test "/etc/ide.d/30-copy-ssh-configs.sh exists and is a file" {
  run test -f /etc/ide.d/30-copy-ssh-configs.sh
  [ "$status" -eq 0 ]
}
@test "/etc/ide.d/30-copy-ssh-configs.sh is owned by ide" {
  run stat -c %U /etc/ide.d/30-copy-ssh-configs.sh
  [ "$status" -eq 0 ]
  [ "$output" = "ide" ]
}
@test "/etc/ide.d/30-copy-ssh-configs.sh is executable" {
  run stat -c %a /etc/ide.d/30-copy-ssh-configs.sh
  [ "$status" -eq 0 ]
  [ "$output" = "755" ]
}

# all the ide scripts can be executed without error and many times
@test "/etc/ide.d/30-copy-ssh-configs.sh returns 0" {
  run /etc/ide.d/30-copy-ssh-configs.sh
  [ "$status" -eq 0 ]
}
@test "/etc/ide.d/50-ide-fix-uid-gid.sh returns 0" {
  run /etc/ide.d/50-ide-fix-uid-gid.sh
  [ "$status" -eq 0 ]
}
@test "/usr/bin/entrypoint.sh returns 0" {
  run /usr/bin/entrypoint.sh whoami 2>&1
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" =~ "ide init finished" ]]
  [ "${lines[2]}" = "ide" ]
}
# secret provided thanks to the custom configuration file
@test "/home/ide/.ssh/id_rsa exists and is a file" {
  run test -f /home/ide/.ssh/id_rsa
  [ "$status" -eq 0 ]
}
@test "/home/ide/.ssh/id_rsa is owned by ide user" {
  run stat -c %U /home/ide/.ssh/id_rsa
  [ "$output" = "ide" ]
  [ "$status" -eq 0 ]
}

# if tests fail and you want to see the actual result (bats does not print them?),
# try e.g.:
# run bash -c "/usr/bin/entrypoint.sh whoami 2>&1 | tee /tmp/result.txt"
# result is in /tmp/result.txt
