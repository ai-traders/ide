describe "get_run_id and similar"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")

  describe 'get_run_id'
    it "returns file name"
      message="$(/bin/bash -c "source ${IDE_PATH} && get_run_id")"
      assert equal "$?" "0"
      # e.g. ide-example-ide-usage-2016-03-08_18-51-09-68509321
      # {2,} == match at least 2 occurrences of a char
      assert do_match "$message" "ide-"
      assert do_match "$message" "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2,}"
    end
  end
  describe 'get_env_vars_file_name'
    it "returns file name"
      run_id="some-random-string-666"
      message="$(/bin/bash -c "source ${IDE_PATH} && get_env_vars_file_name ${run_id}")"
      assert equal "$?" "0"
      # e.g. /tmp/ide-environment-2016-02-17_16-32-29-68192406
      # {2,} == match at least 2 occurrences of a char
      assert do_match "$message" "/tmp/ide-environment-some-random-string-666"
    end
  end
end
