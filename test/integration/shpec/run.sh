describe "ide command: run"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")
  # I'd like here to test that:
  # * no options at all are set -- this is not testable on workstation, because
  # docker container would be interactive (as workstation terminal is) and
  # it would hang all the tests
  # * no other options than --command run are set -- as above
  # * other options than --command run are set

  describe 'when IDE_DRIVER="docker"'
    describe 'when --force_not_interactive is set and docker run cmd is set'
      describe 'easy, common use-case'
        message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive "bash --version && pwd")
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that dryrun is off"
          assert do_match "$message" "dryrun: false"
        end
        it "informs that running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "shows that docker run command has no -ti"
          assert do_not_match "$message" "-ti"
        end
        it "shows docker run command"
          assert do_match "$message" "dummyide:0.0.1 \"bash --version && pwd\""
        end
        it "shows output from run command"
          assert do_match "$message" "GNU bash, version 4.3"
          assert do_match "$message" "/ide/work"
        end
      end
      describe 'custom use-case: custom entrypoint and command after double dash'
        # do not run with debug output, it is not needed for this test
        message=$(cd test/docker/dummyide-usage && IDE_DOCKER_OPTIONS="--entrypoint=/bin/bash" ${IDE_PATH} --force_not_interactive -- -c "echo aaa")
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "echo was run with visible output"
          assert do_match "$message" "aaa"
        end
      end
    end
    describe 'when --no_rm is set'
      publicide_path="test/docker/publicide-usage"
      iderc="${publicide_path}/iderc"
      iderc_txt="${publicide_path}/iderc.txt"

      rm -rf "${iderc}" "${iderc_txt}"
      message=$(cd ${publicide_path} && IDE_LOG_LEVEL=debug ${IDE_PATH} --no_rm whoami)
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "shows that docker run command does not contain --rm"
        assert do_not_match "$message" "--rm"
      end
      it "creates docker container and does not remove it"
        # this is how to get the name of the container
        container_name="$(cat ${iderc_txt})"
        assert do_match "$container_name" "ide-publicide-usage"

        # container is running? should be not removed and be stopped
        assert do_match $(docker inspect  --format {{.State.Running}} ${container_name}) "false"
      end
      docker rm ${container_name}
      rm -rf "${iderc}" "${iderc_txt}"
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when --force_not_interactive is set and docker-compose run cmd is set'
      describe 'docker-compose file version 1'
        docker_networks_count_before_test=$(docker network ls -q | wc -l)
        message=$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'bash --version && pwd')
        docker_networks_count_after_test=$(docker network ls -q | wc -l)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that dryrun is off"
          assert do_match "$message" "dryrun: false"
        end
        it "informs that running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "shows that docker-compose run command has -T"
          assert do_match "$message" "-T"
        end
        it "shows docker run command"
          assert do_match "$message" "default \"bash --version && pwd\""
        end
        it "shows output from run command"
          assert do_match "$message" "GNU bash, version 4.3"
          assert do_match "$message" "/ide/work"
        end
        it "does not need to remove docker network"
          assert do_match "${message}" "No need to remove docker network "
        end
        it "docker networks count does not change"
          assert do_match "${docker_networks_count_before_test}" "${docker_networks_count_after_test}"
        end
      end
      describe 'docker-compose file version 2'
        docker_networks_count_before_test=$(docker network ls -q | wc -l)
        message=$(cd test/docker-compose/publicide-v2-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive -- /bin/sh -c "echo abc")
        docker_networks_count_after_test=$(docker network ls -q | wc -l)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that dryrun is off"
          assert do_match "$message" "dryrun: false"
        end
        it "informs that running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "shows that docker-compose run command has -T"
          assert do_match "$message" "-T"
        end
        it "shows docker run command"
          assert do_match "$message" "default /bin/sh -c \"echo abc\""
        end
        it "removes docker network"
          assert do_match "${message}" "Removed docker network"
        end
        it "docker networks count does not change"
          assert do_match "${docker_networks_count_before_test}" "${docker_networks_count_after_test}"
        end
      end
    end
  end
end
