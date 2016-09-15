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
      message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'bash --version && pwd')"
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
    describe 'when --no_rm is set'
      publicide_path="test/docker/publicide-usage"
      iderc="${publicide_path}/iderc"

      rm -rf "${iderc}"
      message="$(cd ${publicide_path} && IDE_LOG_LEVEL=debug ${IDE_PATH} --no_rm whoami)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "shows that docker run command does not contain --rm"
        assert do_not_match "$message" "--rm"
      end
      it "creates docker container and does not remove it"
        # this is how to get the name of the container
        container_name="$(cat ${iderc})"
        assert do_match "$container_name" "ide-publicide-usage"

        # container is running? should be not removed and be stopped
        assert do_match $(docker inspect  --format {{.State.Running}} ${container_name}) "false"
      end
      docker rm ${container_name}
      rm -rf "${iderc}"
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when --force_not_interactive is set and docker-compose run cmd is set'
      message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'bash --version && pwd')"
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
    end
  end
end
