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
      assert do_match "$message" "error: groupnames other than default are not supported"
    end
  end
  describe "--idefile"
    it "exits 0, if --idefile not set and exists in curent directory"
      message="$(cd examples/gitide-usage && ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "0"
    end
    it "exits 1, if --idefile not set and does not exist in curent directory"
      message="$(cd test && ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "idefile: ${PWD}/test/Idefile does not exist"
    end
    it "exits 1, if zero-length string set"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile '' --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "error: idefile not specified"
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
    describe "command not set"
      it "runs non-interactively if invoked non-interactively"
        # do not use \"\" it will not be counted as empty string
        message="$(/bin/bash -c "cd examples/gitide-usage && ${IDE_PATH} --dryrun")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v"
        assert do_match "$message" "gitide:0.1.1"
        # we don't want quotes if $command not set
        assert do_not_match "$message" "gitide:0.1.1 \"\""
        # this fails on workstation, where terminal is interactive
        # TODO: how to test it? note that I already put test in "/bin/bash -c"
        # assert do_not_match "$message" " -ti"
      end
      it "runs interactively if invoked interactively"
        # do not use \"\" it will not be counted as empty string
        message="$(cd examples/gitide-usage && ${IDE_PATH} --dryrun)"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v"
        # this fails in ideide, where terminal is non-interactive
        # TODO: how to test it?
        # assert do_match "$message" " -ti gitide:0.1.1"
        # we don't want quotes if $command not set
        assert do_not_match "$message" "gitide:0.1.1 \"\""
      end
    end
    describe "command set"
      it "runs non-interactively if invoked non-interactively"
        message="$(cd examples/gitide-usage && ${IDE_PATH} --dryrun some_command)"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v"
        assert do_match "$message" "gitide:0.1.1 \"some_command \""
        # this fails on workstation, where terminal is interactive
        # TODO: how to test it?
        # assert do_not_match "$message" " -ti"
      end
      it "runs interactively if invoked interactively"
        message="$(cd examples/gitide-usage && ${IDE_PATH} --dryrun some_command)"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v"
        # this probably fails in ideide, where terminal is non-interactive
        # TODO: how to test it?
        # assert do_match "$message" " -ti gitide:0.1.1 \"some_command \""
      end
    end
  end
  describe "docker run command, using gitide"
    it "exits 0, constructs correct command"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/examples/gitide-usage/work:/ide/work\ -v\ ${HOME}:/ide/identity:ro\ --env-file="
      assert match "$message" "gitide:0.1.1\ \\\"some_command\ \\\""
    end
    it "exits 0, constructs correct command longer"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command longer)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/examples/gitide-usage/work:/ide/work\ -v\ ${HOME}:/ide/identity:ro\ --env-file="
      assert match "$message" "gitide:0.1.1\ \\\"some_command\ longer\\\""
    end
    it "exits 0, constructs correct command longer longer"
      # do not use \"\" it will not be counted as empty string
      message="$(cd examples/gitide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command longer longer)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/examples/gitide-usage/work:/ide/work\ -v\ ${HOME}:/ide/identity:ro\ --env-file="
      assert match "$message" "gitide:0.1.1\ \\\"some_command\ longer\ longer\\\""
    end
  end
  describe "docker run command, using complexide"
    it "exits 0, constructs correct command"
      # do not use \"\" it will not be counted as empty string
      message="$(IDE_LOG_LEVEL=debug ABC=1 DEF=2 GHI=3 ${IDE_PATH} --idefile test/complexide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "0"
      assert match "$message" "docker\ run\ --rm\ -v\ ${PWD}/test/empty_work_dir:/ide/work\ -v\ ${PWD}/test/empty_home_dir:/ide/identity:ro\ --env-file="
      # "-ti" is not shown in ideide, but it should be already tested
      assert match "$message" "--privileged"
      assert match "$message" "complexide:0.1.0\ \\\"some_command\ \\\""
    end
  end
  describe "docker run command, using invalid-driver-ide"
    it "exits 1"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile test/invalid-driver-ide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "IDE_DRIVER set to bla, supported is only: docker"
    end
  end
  describe "docker run command, using image-not-set-ide"
    it "exits 1"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile test/image-not-set-ide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "IDE_DOCKER_IMAGE not set"
    end
  end
end
