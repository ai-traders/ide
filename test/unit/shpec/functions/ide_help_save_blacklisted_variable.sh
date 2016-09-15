describe "help_save_blacklisted_variable"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")

  it "returns 1 if no argument set"
    message="$(/bin/bash -c "source ${IDE_PATH} && help_save_blacklisted_variable")"
    assert equal "$?" "1"
    assert do_match "$message" "error: env_var not specified"
  end

  it "returns 1 if no env_var starts with IDE_"
    message="$(/bin/bash -c "source ${IDE_PATH} && help_save_blacklisted_variable IDE_ABC")"
    assert equal "$?" "1"
    assert do_match "$message" "error: env_var starts with IDE_"
  end

  it "returns 0 and IDE_ABC=123 if ABC=123 set and IDE_ABC not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 help_save_blacklisted_variable ABC")"
    assert equal "$?" "0"
    assert do_match "$message" "IDE_ABC=123"
  end

  it "returns 0 and IDE_ABC=567 if ABC=123 set and IDE_ABC=567"
    message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 IDE_ABC=567 help_save_blacklisted_variable ABC")"
    assert equal "$?" "0"
    assert do_match "$message" "IDE_ABC=567"
  end
end
