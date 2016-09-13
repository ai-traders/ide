# This acts more like integration tests, but since dry run is used here,
# I treat it as unit tests.
describe "commandline options"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe "--version"
    it "outputs the current version number"
      message="$(${IDE_PATH} --version)"
      assert do_match "$message" "${IDE_PATH} version"
    end
  end
  describe "--idefile"
    it "exits 1, if --idefile not set and Idefile does not exist in curent directory"
      message="$(cd test && ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "idefile: ${PWD}/test/Idefile does not exist"
    end
    it "exits 1, if --idefile set to zero-length string"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile '' --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "error: idefile not specified"
    end
    it "exits 1, if --idefile not set to zero-length string, but the file does not exist"
      message="$(${IDE_PATH} --idefile aa --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "idefile:"
      assert do_match "$message" "aa does not exist"
    end
    it "exits 0, if --idefile not set and Idefile exists in curent directory"
      message="$(cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun some_command)"
      assert equal "$?" "0"
    end
    it "exits 0, if --idefile set and the file exists"
      message="$(${IDE_PATH} --idefile test/docker/complexide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "0"
    end
  end
  # TODO: how to test it?
  # On workstation we run interactively, so any test for non-interactive shell
  # fails; wherease on CI agent we run not-interactively any test for
  # interactive shell fails. I could test with `--force_not_interactive`, but
  # that changes what I want to test.
  # describe "command"
  #   describe "command not set"
  #     it "runs non-interactively if invoked non-interactively"
  #       # do not use \"\" it will not be counted as empty string
  #       # TODO: how to test it? note that I already put test in "/bin/bash -c"
  #       message="$(/bin/bash -c "cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun")"
  #       assert equal "$?" "0"
  #       assert do_match "$message" "docker run --rm -v"
  #       assert do_match "$message" "dummyide:0.0.1"
  #       # we don't want quotes if $command not set
  #       assert do_not_match "$message" "dummyide:0.0.1 \"\""  #
  #       assert do_not_match "$message" " -ti"
  #     end
  #     # this fails in ideide, where terminal is non-interactive
  #     # it "runs interactively if invoked interactively"
  #     #   # do not use \"\" it will not be counted as empty string
  #     #   message="$(cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun)"
  #     #   assert equal "$?" "0"
  #     #   assert do_match "$message" "docker run --rm -v"
  #     #   assert do_match "$message" " -ti dummyide:0.0.1"
  #     #   # we don't want quotes if $command not set
  #     #   assert do_not_match "$message" "dummyide:0.0.1 \"\""
  #     # end
  #   end
  #   describe "command set"
  #     it "runs non-interactively if invoked non-interactively"
  #       message="$(cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun some_command)"
  #       assert equal "$?" "0"
  #       assert do_match "$message" "docker run --rm -v"
  #       assert do_match "$message" "dummyide:0.0.1 \"some_command \""
  #       # this fails on workstation, where terminal is interactive
  #       assert do_not_match "$message" " -ti"
  #     end
  #     it "runs interactively if invoked interactively"
  #       message="$(cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun some_command)"
  #       assert equal "$?" "0"
  #       assert do_match "$message" "docker run --rm -v"
  #       # this probably fails in ideide, where terminal is non-interactive
  #       assert do_match "$message" " -ti dummyide:0.0.1 \"some_command \""
  #     end
  #   end
  # end
  describe "docker driver"
    it "exits 0, if some command set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun /bin/bash -c \"aaa\")"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
      assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \"aaa\"\""
    end
    it "exits 0, if no command set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun)"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
      assert do_match "$message" "dummyide:0.0.1"
      # we don't want quotes if $command not set
      assert do_not_match "$message" "dummyide:0.0.1 \"\""
    end
    it "exits 0, if complex IDE_WORK and IDE_IDENTITY set"
      # do not use \"\" it will not be counted as empty string
      message="$(IDE_LOG_LEVEL=debug ABC=1 DEF=2 GHI=3 ${IDE_PATH} --idefile test/docker/complexide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/empty_work_dir:/ide/work -v ${PWD}/test/docker/empty_home_dir:/ide/identity:ro --env-file="
      # "-ti" is not shown in ideide, but it should be already tested
      assert do_match "$message" " --privileged"
      assert do_match "$message" "complexide:0.1.0 \"some_command \""
    end
    it "exits 1, if IDE_DRIVER set to bla"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile test/docker/invalid-driver-ide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "IDE_DRIVER set to bla, supported are: docker, docker-compose"
    end
    it "exits 1, if IDE_DOCKER_IMAGE not set"
      # do not use \"\" it will not be counted as empty string
      message="$(${IDE_PATH} --idefile test/docker/image-not-set-ide-usage/Idefile --dryrun some_command)"
      assert equal "$?" "1"
      assert do_match "$message" "IDE_DOCKER_IMAGE not set"
    end
  end
  describe "docker-compose driver"
    it "exits 0, if some command set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash -c \"aaa\")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\""
      assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
      assert do_match "$message" "run --rm -T default \"/bin/bash -c \"aaa\"\""
    end
    it "exits 0, if no command set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\""
      assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
      assert do_not_match "$message" "run --rm -T default \"\""
    end
    it "exits 0, if custom docker-compose file set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker-compose/custom_dc_file && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash -c \"aaa\")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\""
      assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/custom_dc_file/bla.yml -p"
      assert do_match "$message" "run --rm -T default \"/bin/bash -c \"aaa\"\""
    end
    it "exits 0, if custom docker-compose options set and command set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker-compose/custom_dc_options && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash -c \"aaa\")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\""
      assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/custom_dc_options/docker-compose.yml -p"
      assert do_match "$message" "run --rm -T --bla default \"/bin/bash -c \"aaa\"\""
    end
    it "exits 0, if custom docker-compose options set and command not set"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker-compose/custom_dc_options && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\""
      assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/custom_dc_options/docker-compose.yml -p"
      assert do_match "$message" "run --rm -T --bla default"
    end
    it "exits 1, if docker-compose file does not exist"
      # do not use \"\" it will not be counted as empty string
      message="$(cd test/docker-compose/no_dc_file && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash -c \"aaa\")"
      assert equal "$?" "1"
      assert do_match "$message" "IDE_DOCKER_COMPOSE_FILE set to"
      assert do_match "$message" "does not exist"
    end
  end
end