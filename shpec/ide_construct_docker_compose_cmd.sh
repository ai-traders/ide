describe "construct_docker_compose_command"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")

  it "succeeds if everything set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file true ide-abc123 /tmp/d-c.yml /bin/bash --some-option")"
    assert equal "$?" "0"
    assert do_match "$message" "ENV_FILE_NAME=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm --some-option default \"/bin/bash\""
  end
  it "succeeds if everything set and not interactive"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file false ide-abc123 /tmp/d-c.yml /bin/bash --some-option")"
    assert equal "$?" "0"
    assert do_match "$message" "ENV_FILE_NAME=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm -T --some-option default \"/bin/bash\""
  end
  it "succeeds if command not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file true ide-abc123 /tmp/d-c.yml \"\" --some-option")"
    assert equal "$?" "0"
    assert do_match "$message" "ENV_FILE_NAME=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm --some-option default"
  end
  it "succeeds if options not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file true ide-abc123 /tmp/d-c.yml /bin/bash \"\"")"
    assert equal "$?" "0"
    assert do_match "$message" "ENV_FILE_NAME=\"/tmp/env_file\" docker-compose -f /tmp/d-c.yml -p ide-abc123 run --rm default"
  end
  it "fails if env file not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command \"\" true ide-abc123 /tmp/d-c.yml /bin/bash --some-option")"
    assert equal "$?" "1"
  end
  it "fails if run_interactively not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file \"\" ide-abc123 /tmp/d-c.yml /bin/bash --some-option")"
    assert equal "$?" "1"
  end
  it "fails if run_id not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file true \"\" /tmp/d-c.yml /bin/bash --some-option")"
    assert equal "$?" "1"
  end
  it "fails if docker_compose_file not set"
    message="$(/bin/bash -c "source ${IDE_PATH} && construct_docker_compose_command /tmp/env_file true ide-abc123 \"\" /bin/bash --some-option")"
    assert equal "$?" "1"
  end
end
