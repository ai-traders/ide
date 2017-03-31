describe "ide command: run"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker-compose"'
    describe 'idefile verification'
      describe 'when IDE_DOCKER_COMPOSE_FILE does not exist'
        message="$(cd test/docker-compose/no_dc_file && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that IDE_DOCKER_COMPOSE_FILE does not exist"
          assert do_match "$message" "docker-compose.yml which does not exist"
        end
      end
      describe 'when custom IDE_DOCKER_COMPOSE_FILE set and exists'
        message="$(cd test/docker-compose/custom_dc_file && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs which IDE_DOCKER_COMPOSE_FILE is used"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/custom_dc_file/bla.yml -p"
        end
      end
    end
    describe '--force_not_interactive'
      describe 'when --force_not_interactive is set and docker-compose run cmd is set'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive echo sth)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "docker-compose -T option is on"
          assert do_match "$message" "-T"
        end
        it "informs about docker-compose run cmd"
          assert do_match "$message" "default \"echo sth\""
        end
      end
      describe 'when --force_not_interactive is set and docker-compose run cmd is not set'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "docker-compose -T option is on"
          assert do_match "$message" "-T"
        end
      end
    end
    describe '--no_rm option'
      publicide_path_dc="test/docker-compose/publicide-usage"
      iderc_dc="${publicide_path_dc}/iderc"

      describe 'when --no_rm is set'
        rm -rf "${iderc_dc}"
        message="$(cd ${publicide_path_dc} && ${IDE_PATH} --no_rm --dryrun)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that this option is not implemented"
          assert do_match "$message" "Not implemented feature: '--no_rm' for driver: docker-compose"
        end
        rm -rf "${iderc_dc}"
      end
    end
    describe 'when using different docker-compose run commands'
      describe 'when one-word command set without quotes'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          # outside quotes are added
          assert do_match "$message" "run --rm -T default \"/bin/bash\""
        end
      end
      describe 'when one-word command set with double quotes'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive \"/bin/bash\")"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "run --rm -T default \"/bin/bash\""
        end
      end
      describe 'when one-word command set with single quotes'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive '/bin/bash')"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          # single quotes are treated the same as no quotes
          assert do_match "$message" "run --rm -T default \"/bin/bash\""
        end
      end
      describe 'when multi-word command set without quotes'
        # this is not recommended, but test that that behavior is expected
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash -c \"aaa\")"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "run --rm -T default /bin/bash -c \"aaa\""
        end
      end
      describe 'when multi-word command set with double quotes'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive \"/bin/bash -c \\\"aaa\\\"\")"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "run --rm -T default \"/bin/bash -c \\\\\"aaa\\\\\"\""
        end
      end
      describe 'when multi-word command set with single quotes'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive '/bin/bash -c "aaa"')"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "run --rm -T default /bin/bash -c \"aaa\""
        end
      end
      describe 'when no command set'
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker-compose run command"
          assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/default/docker-compose.yml -p"
          assert do_not_match "$message" "run --rm -T default \"\""
        end
      end
    end
    describe 'when custom docker-compose options set and command set'
      message="$(cd test/docker-compose/custom_dc_options && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive /bin/bash -c \"aaa\")"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs about docker-compose run command"
        assert do_match "$message" "ENV_FILE=\""
        assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/custom_dc_options/docker-compose.yml -p"
        assert do_match "$message" "run --rm -T --bla default /bin/bash -c \"aaa\""
      end
    end
    describe 'when custom docker-compose options set and command not set'
      message="$(cd test/docker-compose/custom_dc_options && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs about docker-compose run command"
        assert do_match "$message" "ENV_FILE=\""
        assert do_match "$message" "docker-compose -f ${PWD}/test/docker-compose/custom_dc_options/docker-compose.yml -p"
        assert do_match "$message" "run --rm -T --bla default"
      end
    end
  end
end
