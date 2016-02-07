describe "env_var_already_in_array"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")
  env_var='ABC'
  # commented out beause it results in:
  # /usr/local/bin/shpec: 5: shpec/ide_env_var_already_in_array.sh: Syntax error: "(" unexpected
  # docker_envs_array=(one two three)
  docker_envs_array[0]="ABC=99"
  docker_envs_array[1]="CDE=100"
  docker_envs_array[2]="EFG=12"

  it "returns 1 if array not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && env_var_already_in_array")"
    assert equal "$?" "1"
    assert do_match "$message" "error: array not specified"
  end

  it "returns 1 if env_var not set"
    # actually env_var is set, but the second argument (which should be env_var)
    # is not set. But I cannot pass here docker_envs_array as this test is failed
    # then.
    message="$(/bin/bash -c "source ${IDE_PATH} && env_var_already_in_array docker_envs_array[@] ")"
    assert equal "$?" "1"
    assert do_match "$message" "error: env_var not specified"
  end

  it "returns 0 if set"
    message="$(/bin/bash -c "source ${IDE_PATH} && env_var_already_in_array "docker_envs_array[@]" ${env_var}")"
    assert equal "$?" "0"
    assert do_match "$message" "true"
  end

  # it "returns 1 if no env_var starts with IDE_"
  #   message="$(/bin/bash -c "source ${IDE_PATH} && help_save_blacklisted_variable IDE_ABC")"
  #   assert equal "$?" "1"
  #   assert do_match "$message" "error: env_var starts with IDE_"
  # end
  #
  # it "returns 0 and IDE_ABC=123 if ABC=123 set and IDE_ABC not set"
  #   message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 help_save_blacklisted_variable ABC")"
  #   assert equal "$?" "0"
  #   assert do_match "$message" "IDE_ABC=123"
  # end
  #
  # it "returns 0 and IDE_ABC=567 if ABC=123 set and IDE_ABC=567"
  #   message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 IDE_ABC=567 help_save_blacklisted_variable ABC")"
  #   assert equal "$?" "0"
  #   assert do_match "$message" "IDE_ABC=567"
  # end
end
