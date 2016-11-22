describe "verify_docker_compose_file"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")
  unit_shpec_path="./test/unit/shpec"

  it "succeeds if good.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/good.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "0"
    assert equal "$message" ""
  end
  it "succeeds if good_v2.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/good_v2.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "0"
    assert equal "$message" ""
  end
  it "fails if no_ide_identity.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/no_ide_identity.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "1"
    assert do_match "$message" "does not contain IDE_IDENTITY"
  end
  it "fails if no_ide_work.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/no_ide_work.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "1"
    assert do_match "$message" "does not contain IDE_WORK"
  end
  it "fails if no_env_file.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/no_env_file.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "1"
    assert do_match "$message" "does not contain ENV_FILE"
  end
  it "fails if no_read_only.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/no_read_only.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "1"
    assert do_match "$message" "does not contain \":ro\" when mounting IDE_IDENTITY"
  end
  # FIXME: make docker-compose config work
  # it "fails if no_default_container.yml"
  #   docker_compose_file="${unit_shpec_path}/docker-compose-files/no_default_container.yml"
  #   message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
  #   assert equal "$?" "1"
  #   assert do_match "$message" "does not contain \"default\" container"
  # end
  it "fails if no_default_container1.yml"
    docker_compose_file="${unit_shpec_path}/docker-compose-files/no_default_container1.yml"
    message="$(/bin/bash -c "source ${IDE_PATH} && verify_docker_compose_file ${docker_compose_file}")"
    assert equal "$?" "1"
    assert do_match "$message" "does not contain \"default\" container"
  end
end
