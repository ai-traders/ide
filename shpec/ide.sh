describe "commandline options"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe "--version"
    it "outputs the current version number"
      message="$(${IDE_PATH} --version)"
      assert equal "$message" "${IDE_PATH} version 0.1.0"
    end
  end
  describe "--group"
    it "exits 1, groups are not supported"
      message="$(${IDE_PATH} --dryrun --group \"\")"
      assert equal "$?" "1"
      assert equal "$message" "groupnames other than default are not supported"
    end
  end
  describe "--idefile"
    it "exits 0, if --idefile not set and exists in curent directory"
      message="$(cd examples/gitide && ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "0"
    end
    it "exits 1, if --idefile not set and does not exist in curent directory"
      message="$(${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "idefile: ${PWD}/Idefile does not exist"
    end
    it "exits 1, if zero-length string set"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile '' --dryrun some_command)"
      assert equal "$?" "1"
      assert equal "$message" "idefile not specified"
    end
    it "exits 1, if not zero-length string set, but the file does not exist"
      message="$(${IDE_PATH} --idefile aa --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "idefile:"
      assert do_match "$message" "aa does not exist"
    end
    it "exits 0, if not zero-length string set and the file exists"
      message="$(${IDE_PATH} --idefile test/complexide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "0"
    end
  end
  describe "command"
    it "exits 0, if zero-length command set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide && ${IDE_PATH} --dryrun)"
      assert equal "$?" "0"
      assert do_match "$message" "docker run -ti --rm -v"
      assert do_match "$message" "gitide:0.1.0 \"\""
    end
    it "exits 0, if not zero-length command set"
      message="$(cd examples/gitide && ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v"
      assert do_match "$message" "gitide:0.1.0 \"some_command \""
    end
  end
  describe "docker run command, using gitide"
    it "exits 0, constructs correct command"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/examples/gitide/work:/ide/work\ -v\ ${HOME}:/ide/identity:ro\ --env-file="
      assert match "$message" "gitide:0.1.0\ \\\"some_command\ \\\""
    end
    it "exits 0, constructs correct command longer"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command longer)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/examples/gitide/work:/ide/work\ -v\ ${HOME}:/ide/identity:ro\ --env-file="
      assert match "$message" "gitide:0.1.0\ \\\"some_command\ longer\\\""
    end
    it "exits 0, constructs correct command longer longer"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command longer longer)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/examples/gitide/work:/ide/work\ -v\ ${HOME}:/ide/identity:ro\ --env-file="
      assert match "$message" "gitide:0.1.0\ \\\"some_command\ longer\ longer\\\""
    end
  end
  describe "docker run command, using complexide"
    it "exits 0, constructs correct command"
      # do not use \"\" it will not be counted as empty string
      message="$(IDE_LOG_LEVEL=debug ABC=1 DEF=2 GHI=3 ${IDE_PATH} --idefile test/complexide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/test/empty_work_dir:/ide/work\ -v\ ${PWD}/test/empty_home_dir:/ide/identity:ro\ --env-file="
      assert match "$message" "--privileged\ complexide:0.1.0\ \\\"some_command\ \\\""
    end
  end
  describe "docker run command, using invalid-driver-ide"
    it "exits 1"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile test/invalid-driver-ide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "1"
      assert equal "$message" "IDE_DRIVER set to bla, supported is only: docker"
    end
  end
  describe "docker run command, using image-not-set-ide"
    it "exits 1"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile test/image-not-set-ide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "1"
      assert equal "$message" "IDE_DOCKER_IMAGE not set"
    end
  end
end
