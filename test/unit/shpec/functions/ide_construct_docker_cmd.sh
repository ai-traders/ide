describe "construct_docker_command"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")

  describe "construct_docker_command"
    it "fails if env_file not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command \"\" true my_container my_image /tmp/work /home/user true /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "env_file not specified"
    end
    it "fails if run_interactively not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file \"\" my_container my_image /tmp/work /home/user true /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "run_interactively not specified"
    end
    it "fails if container_name not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true \"\" my_image /tmp/work /home/user true /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "container_name not specified"
    end
    it "fails if image_name not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container \"\" /tmp/work /home/user true /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "image_name not specified"
    end
    it "fails if ide_work not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image \"\" /home/user true /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "ide_work not specified"
    end
    it "fails if ide_identity not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work \"\" true /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "ide_identity not specified"
    end
    it "succeeds if everything set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user true /bin/bash --some-option")"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
      assert do_match "$message" "--some-option -ti --name my_container my_image \"/bin/bash\""
    end
    it "succeeds if not running interactively"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file false my_container my_image /tmp/work /home/user true /bin/bash --some-option")"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
      assert do_match "$message" "--some-option --name my_container my_image \"/bin/bash\""
    end
    it "succeeds if long command set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user true \"/bin/bash -c 'aaa'\" --some-option")"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
      assert do_match "$message" "--some-option -ti --name my_container my_image \"/bin/bash -c 'aaa'\""
    end
    it "succeeds if long command set and no option"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user true \"/bin/bash -c 'aaa'\"")"
      assert equal "$?" "0"
      assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
      assert do_match "$message" "-ti --name my_container my_image \"/bin/bash -c 'aaa'\""
    end
    describe "graphical mode"
      it "succeeds if DISPLAY set"
        # do not use \"\" it will not be counted as empty string
        message="$(/bin/bash -c "source ${IDE_PATH} && IDE_LOG_LEVEL=debug DISPLAY=bla construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user true \"/bin/bash\" --some-option")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\" -v /tmp/.X11-unix:/tmp/.X11-unix --some-option -ti --name my_container my_image \"/bin/bash\""
      end
      it "succeeds if DISPLAY not set"
        # do not use \"\" it will not be counted as empty string
        message="$(/bin/bash -c "source ${IDE_PATH} && unset DISPLAY && IDE_LOG_LEVEL=debug construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user true \"/bin/bash\" --some-option")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\" --some-option -ti --name my_container my_image \"/bin/bash\""
      end
    end
    describe "remove_containers"
      it "succeeds if remove_containers set to false"
        message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user false /bin/bash --some-option")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
        assert do_match "$message" "--some-option -ti --name my_container my_image \"/bin/bash\""
      end
      it "succeeds if remove_containers set to true"
        message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user true /bin/bash --some-option")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run --rm -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
        assert do_match "$message" "--some-option -ti --name my_container my_image \"/bin/bash\""
      end
      it "fails if remove_containers not set"
        message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user \"\"  /bin/bash --some-option")"
        assert equal "$?" "1"
        assert do_match "$message" "remove_containers not specified"
      end
      it "succeeds if remove_containers set to false and no command set"
        message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user false \"\" --some-option")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
        assert do_match "$message" "--some-option -ti --name my_container my_image"
      end
      it "succeeds if remove_containers set to false and no options set"
        message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_command /tmp/env_file true my_container my_image /tmp/work /home/user false /bin/bash")"
        assert equal "$?" "0"
        assert do_match "$message" "docker run -v /tmp/work:/ide/work -v /home/user:/ide/identity:ro --env-file=\"/tmp/env_file\""
        assert do_match "$message" "-ti --name my_container my_image \"/bin/bash\""
      end
    end
  end
end
