load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

IDE_PATH="../ide"

@test "/usr/bin/entrypoint.sh returns 0" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested \"pwd && whoami\""
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "ide init finished"
  assert_line --partial "/ide/work"
  refute_output --partial "root"
  assert_equal "$status" 0
}
@test "bash is installed" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested \"bash --version\""
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "GNU bash"
  assert_equal "$status" 0
}
@test "environment is correctly set" {
  run /bin/bash -c "${IDE_PATH} --idefile Idefile.to_be_tested \"env\""
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "ide_work=/ide/work"
  assert_equal "$status" 0
}
@test "environment is correctly set when custom IDE_WORK_INNER" {
  run /bin/bash -c "IDE_WORK_INNER=/tmp/mywork ${IDE_PATH} --idefile Idefile.to_be_tested \"env\""
  # this is printed on test failure
  echo "output: $output"
  assert_line --partial "ide_work=/tmp/mywork"
  assert_equal "$status" 0
}
