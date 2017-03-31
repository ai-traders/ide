describe "ide command: run"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'common for any IDE_DRIVER'
    describe "--dryrun"
      describe 'when --dryrun set'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that dryrun is on"
          assert do_match "$message" "dryrun: true"
        end
      end
    end
    describe "--idefile"
      describe 'when --idefile not set and Idefile does not exist in curent directory'
        message="$(cd test && ${IDE_PATH} --dryrun)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that Idefile does not exist"
          assert do_match "$message" "idefile: ${PWD}/test/Idefile does not exist"
        end
      end
      describe 'when --idefile set to zero-length string'
        # do not use \"\" it will not be counted as empty string
        message="$(${IDE_PATH} --idefile '' --dryrun some_command)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that Idefile path set to zero-length string"
          assert do_match "$message" "error: idefile path set to zero-length string"
        end
      end
      describe 'when --idefile set to not existent file'
        message="$(${IDE_PATH} --idefile aa --dryrun some_command)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that Idefile does not exist"
          assert do_match "$message" "aa does not exist"
        end
      end
      describe 'when --idefile not set but Idefile exists in curent directory'
        message="$(cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun some_command)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
      end
      describe 'when --idefile set and the file exists'
        message="$(${IDE_PATH} --idefile test/docker/complexide-usage/Idefile --dryrun some_command)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
      end
    end
    describe 'idefile verification'
      describe 'when IDE_DRIVER set to bla'
        message="$(${IDE_PATH} --idefile test/docker/invalid-driver-ide-usage/Idefile --dryrun some_command)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that invalid IDE_DRIVER set"
          assert do_match "$message" "IDE_DRIVER set to bla, supported are: docker, docker-compose"
        end
      end
    end
  end
  describe 'when IDE_DRIVER="docker"'
    describe 'idefile verification'
      describe 'when IDE_DOCKER_IMAGE not set'
        message="$(${IDE_PATH} --idefile test/docker/image-not-set-ide-usage/Idefile --dryrun some_command)"
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that IDE_DOCKER_IMAGE not set"
        assert do_match "$message" "IDE_DOCKER_IMAGE not set"
        end
      end
    end
    describe '--force_not_interactive and --not_i'
      describe 'when --force_not_interactive is set'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "docker run command does not match -ti"
          assert do_not_match "$message" "-ti"
        end
      end
      describe 'when --not_i is set'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --not_i)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "docker run command does not match -ti"
          assert do_not_match "$message" "-ti"
        end
      end
      describe 'when --not_i is set and docker run command is set'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --not_i echo sth)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about running not interactively"
          assert do_match "$message" "run_interactively: false"
        end
        it "informs about docker run command user"
          assert do_match "$message" "dummyide:0.0.1 \"echo sth\""
        end
        it "docker run command does not match -ti"
          assert do_not_match "$message" "-ti"
        end
      end
    end
    describe '--no_rm option'
      publicide_path="test/docker/publicide-usage"
      iderc_txt="${publicide_path}/iderc.txt"
      iderc="${publicide_path}/iderc"

      describe 'when --no_rm is set'
        rm -rf "${iderc}" "${iderc_txt}"
        message="$(cd ${publicide_path} && ${IDE_PATH} --no_rm --dryrun)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "creates iderc.txt file"
          file_exists="$(test -f ${iderc_txt})"
          assert equal "$?" "0"
        end
        it "creates iderc file"
          file_exists="$(test -f ${iderc})"
          assert equal "$?" "0"
        end
        it "does not create docker container"
          assert do_not_match "$message" "--rm"
        end
        rm -rf "${iderc}" "${iderc_txt}"
      end
    end
    describe 'when using different docker run commands'
      describe 'when one-word command set without quotes'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun /bin/bash)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          # outside quotes are added
          assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
        end
      end
      describe 'when one-word command set with double quotes'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun \"/bin/bash\")"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
        end
      end
      describe 'when one-word command set with single quotes'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun '/bin/bash')"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          # single quotes are treated the same as no quotes
          assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
        end
      end
      describe 'when multi-word command set without quotes'
        # this is not recommended, but test that that behavior is expected
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun /bin/bash -c \"aaa\")"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "dummyide:0.0.1 /bin/bash -c \"aaa\""
        end
      end
      describe 'when multi-word command set with double quotes'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun \"/bin/bash -c \\\"aaa\\\"\")"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"aaa\\\\\"\""
        end
      end
      describe 'when multi-word command set with single quotes'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun '/bin/bash -c "aaa"')"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          # double quotes not added, because the command already contains
          # double quotes
          assert do_match "$message" "dummyide:0.0.1 /bin/bash -c \"aaa\""
        end
      end
      describe 'when no command set'
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs about docker run command"
          assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
          assert do_match "$message" "dummyide:0.0.1"
        end
        it "informs that no empty quotes are used"
          # we don't want quotes if $command not set
          assert do_not_match "$message" "dummyide:0.0.1 \"\""
        end
      end
      describe 'when double dash (--) used'
        describe 'when one-word command set without quotes'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- /bin/bash)"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # outside quotes are added
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
        describe 'when one-word command set without quotes, prefixed with many spaces'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --    /bin/bash)"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # outside quotes are added
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
        describe 'when one-word command set with double quotes'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- \"/bin/bash\")"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # double quotes not added, because the command already contains
            # double quotes
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
        describe 'when one-word command set with single quotes'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- '/bin/bash')"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # single quotes are treated the same as no quotes
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
        describe 'when multi-word command set without quotes'
          # this is not recommended, but test that that behavior is expected
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- /bin/bash -c \"aaa\")"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # double quotes not added, because the command already contains
            # double quotes
            assert do_match "$message" "dummyide:0.0.1 /bin/bash -c \"aaa\""
          end
        end
        describe 'when multi-word command set with double quotes'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- \"/bin/bash -c \\\"aaa\\\"\")"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # double quotes not added, because the command already contains
            # double quotes
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"aaa\\\\\"\""
          end
        end
        describe 'when multi-word command set with single quotes'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- '/bin/bash -c "aaa"')"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # double quotes not added, because the command already contains
            # double quotes
            assert do_match "$message" "dummyide:0.0.1 /bin/bash -c \"aaa\""
          end
        end
        describe 'when multi-word command, no quotes, starts with dash'
          message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- -c \"aaa\")"
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # double quotes not added, because the command already contains
            # double quotes
            assert do_match "$message" "dummyide:0.0.1 -c \"aaa\""
          end
        end
      end
    end
    describe 'when custom IDE_WORK and IDE_IDENTITY set as env variables'
      message="$(IDE_LOG_LEVEL=debug ABC=1 DEF=2 GHI=3 ${IDE_PATH} --idefile test/docker/complexide-usage/Idefile --dryrun some_command)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs about docker run command"
        assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/empty_work_dir:/ide/work -v ${PWD}/test/docker/empty_home_dir:/ide/identity:ro --env-file="
        assert do_match "$message" "--privileged"
      end
      it "informs that no empty quotes are used"
      assert do_match "$message" "complexide:0.1.0 \"some_command\""
      end
    end
  end
end
