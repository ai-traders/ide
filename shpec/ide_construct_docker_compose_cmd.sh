describe "construct_docker_compose_run_command"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")

  describe "construct_docker_compose_command_part1"
    it "fails if env_file not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command_part1 \"\" /tmp/d-c.yml ide-abc123")"
      assert equal "$?" "1"
      assert do_match "$message" "env_file not specified"
    end
    it "fails if docker_compose_file not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command_part1 /tmp/env_file \"\" ide-abc123")"
      assert equal "$?" "1"
      assert do_match "$message" "docker_compose_file not specified"
    end
    it "fails if project_name not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command_part1 /tmp/env_file /tmp/d-c.yml \"\"")"
      assert equal "$?" "1"
      assert do_match "$message" "project_name not specified"
    end
    it "succeeds if everything set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command_part1 /tmp/env_file /tmp/d-c.yml ide-abc123")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123"
    end
  end

  describe "construct_docker_compose_run_command"
    it "fails if env_file not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_run_command \"\" /tmp/d-c.yml ide-abc123")"
      assert equal "$?" "1"
      assert do_match "$message" "env_file not specified"
    end
    it "fails if run_interactively not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_run_command /tmp/env_file /tmp/d-c.yml ide-abc123 \"\" /bin/bash --some-option")"
      assert equal "$?" "1"
      assert do_match "$message" "run_interactively not specified"
    end
    it "succeeds if everything set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_run_command /tmp/env_file /tmp/d-c.yml ide-abc123 true /bin/bash --some-option")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm --some-option default \"/bin/bash\""
    end
    it "succeeds if everything set and not interactive"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_run_command /tmp/env_file /tmp/d-c.yml ide-abc123 false /bin/bash --some-option")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm -T --some-option default \"/bin/bash\""
    end
    it "succeeds if command not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_run_command /tmp/env_file /tmp/d-c.yml ide-abc123 true \"\" --some-option")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm --some-option default"
    end
    it "succeeds if options not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_run_command /tmp/env_file /tmp/d-c.yml ide-abc123 true /bin/bash \"\"")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm default"
    end
  end

  describe "construct_docker_compose_stop_command"
    it "fails if env_file not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_stop_command \"\" /tmp/d-c.yml ide-abc123")"
      assert equal "$?" "1"
      assert do_match "$message" "env_file not specified"
    end
    it "succeeds if everything set"
      message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_stop_command /tmp/env_file /tmp/d-c.yml ide-abc123")"
      assert equal "$?" "0"
      assert do_match "$message" "ENV_FILE=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 stop"
    end
  end
end
