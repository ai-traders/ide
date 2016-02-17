describe "get_env_vars_file_name"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")

  describe 'get_env_vars_file_name'
    it "returns file name"
      message="$(/bin/bash -c "source ${IDE_PATH} && get_env_vars_file_name")"
      # e.g. /tmp/ide/environment-2016-02-17_16-32-29-68192406
      # {2,} == match at least 2 occurrences of a char
      assert do_match "$message" "/tmp/ide/environment-[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2,}"
    end
  end
end
