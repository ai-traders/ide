describe "ide command: run"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")
  # Do not ever quote the output of ide command in tests or else it can be
  # not credible. E.g.
  # message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- -c "echo aaa")
  # could result in command being: -c echo aaa, which will be later put in quotes:
  # "-c echo aaa". So this is a false positive test.
  # while
  # message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- -c \"echo aaa\")"
  # could result in command being -c "echo aaa"
  # The latter is the desired one, but the end user would rarely if ever run ide this way.

  describe 'common for any IDE_DRIVER'
    describe 'when invalid option set: starts with double dash'
      message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --invalid-option 2>&1)
      exit_status="$?"
      it "exits with status 1"
        assert equal "$exit_status" "1"
      end
      it "informs about invalid option"
        assert do_match "$message" "IDE error: Invalid option: '--invalid-option'"
      end
    end
    describe 'when invalid option set: starts with single dash'
      message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -invalid-option 2>&1)
      exit_status="$?"
      it "exits with status 1"
        assert equal "$exit_status" "1"
      end
      it "informs about invalid option"
        assert do_match "$message" "IDE error: Invalid option: '-invalid-option'"
      end
    end
    describe 'when invalid option set: starts with single dash, single letter'
      message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -a 2>&1)
      exit_status="$?"
      it "exits with status 1"
        assert equal "$exit_status" "1"
      end
      it "informs about invalid option"
        assert do_match "$message" "IDE error: Invalid option: '-a'"
      end
    end
    describe "--dryrun"
      describe 'when --dryrun set'
        message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun some_command)
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
        message=$(cd test && ${IDE_PATH} --dryrun)
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
        message=$(${IDE_PATH} --idefile '' --dryrun some_command)
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that Idefile path set to zero-length string"
          assert do_match "$message" "error: idefile path set to zero-length string"
        end
      end
      describe 'when --idefile set to not existent file'
        message=$(${IDE_PATH} --idefile aa --dryrun some_command)
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that Idefile does not exist"
          assert do_match "$message" "aa does not exist"
        end
      end
      describe 'when --idefile not set but Idefile exists in curent directory'
        message=$(cd test/docker/dummyide-usage && ${IDE_PATH} --dryrun some_command)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
      end
      describe 'when --idefile set and the file exists'
        message=$(${IDE_PATH} --idefile test/docker/complexide-usage/Idefile --dryrun some_command)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
      end
    end
    describe 'idefile verification'
      describe 'when IDE_DRIVER set to bla'
        message=$(${IDE_PATH} --idefile test/docker/invalid-driver-ide-usage/Idefile --dryrun some_command)
        exit_status="$?"
        it "exits with status 1"
          assert equal "$exit_status" "1"
        end
        it "informs that invalid IDE_DRIVER set"
          assert do_match "$message" "IDE_DRIVER set to bla, supported are: docker, docker-compose"
        end
      end
    end
    describe 'when custom IDE_WORK and IDE_IDENTITY set as env variables'
      message=$(IDE_LOG_LEVEL=debug ABC=1 DEF=2 GHI=3 ${IDE_PATH} --idefile test/docker/complexide-usage/Idefile --dryrun some_command)
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
    describe 'when using root'
      describe 'when running as root'
        message=$(cd test/docker/dummyide-usage && sudo IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun 2>&1)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "warns about running as root"
          assert do_match "$message" "IDE warn: Running as root. This is highly inadvisable."
        end
      end
      describe 'when current directory is owned by root'
        cp -r test/docker/dummyide-usage test/docker/dummyide-usage-root-owned
        sudo chown root:root -R test/docker/dummyide-usage-root-owned
        message=$(cd test/docker/dummyide-usage-root-owned && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun 2>&1)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "warns that directory is owned by root"
          assert do_match "$message" "IDE warn: IDE_WORK directory is owned by root. This is highly inadvisable."
        end
        sudo rm -rf test/docker/dummyide-usage-root-owned
      end
    end
    describe 'when using different docker run commands'
      describe 'when no command set'
        message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun)
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
      describe 'when command without spaces: /bin/bash'
        describe 'when no outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun /bin/bash)
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
        describe 'when no outer quotes but after double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- /bin/bash)
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
        describe 'when no outer quotes but after double dash and prefixed with many spaces'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --    /bin/bash)
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
        describe 'when single outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun '/bin/bash')
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
        describe 'when single outer quotes and after double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- '/bin/bash')
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
        describe 'when double outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun "/bin/bash")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
        describe 'when double outer quotes and after double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- "/bin/bash")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash\""
          end
        end
      end
      describe 'when command with spaces and no inner quotation needed: /bin/bash -c "whoami"'
        describe 'when no outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun /bin/bash -c "whoami")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # it's ok that quotes around whoami are not needed, because whoami
            # is a one word, so this will work fine
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c whoami\""
          end
        end
        describe 'when no outer quotes but prefixed with double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- /bin/bash -c "whoami")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # it's ok that quotes around whoami are not needed, because whoami
            # is a one word, so this will work fine
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c whoami\""
          end
        end
        describe 'when single outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun '/bin/bash -c "whoami"')
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"whoami\\\\\"\""
          end
        end
        describe 'when single outer quotes and prefixed with double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- '/bin/bash -c "whoami"')
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"whoami\\\\\"\""
          end
        end
        describe 'when double outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun "/bin/bash -c \"whoami\"")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"whoami\\\\\"\""
          end
        end
        describe 'when double outer quotes and prefixed with double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- "/bin/bash -c \"whoami\"")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"whoami\\\\\"\""
          end
        end
      end
      describe 'when command with spaces and inner quotation needed: /bin/bash -c "echo aaa" && echo bbb'
        # when no outer quotes - the command after && would not be run in ide
        describe 'when single outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun '/bin/bash -c "echo aaa" && echo bbb')
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"echo aaa\\\\\" && echo bbb\""
          end
        end
        describe 'when single outer quotes and after double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- '/bin/bash -c "echo aaa" && echo bbb')
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"echo aaa\\\\\" && echo bbb\""
          end
        end
        describe 'when double outer quotes'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun "/bin/bash -c \"echo aaa\" && echo bbb")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"echo aaa\\\\\" && echo bbb\""
          end
        end
        describe 'when double outer quotes and double dash'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- "/bin/bash -c \"echo aaa\" && echo bbb")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            assert do_match "$message" "dummyide:0.0.1 \"/bin/bash -c \\\\\"echo aaa\\\\\" && echo bbb\""
          end
        end
      end
      describe 'when command with spaces and starts with dash'
        describe 'when no outer quotes'
          # this is the reason why we support double dash
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -c "echo aaa" 2>&1)
          exit_status="$?"
          it "exits with status 1"
            assert equal "$exit_status" "1"
          end
          it "informs about docker run command"
            assert do_match "$message" "IDE error: Invalid option: '-c'"
          end
        end
        describe 'when no outer quotes and double dash used'
          message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun -- -c "echo aaa")
          exit_status="$?"
          it "exits with status 0"
            assert equal "$exit_status" "0"
          end
          it "informs about docker run command"
            assert do_match "$message" "docker run --rm -v ${PWD}/test/docker/dummyide-usage/work:/ide/work -v ${HOME}:/ide/identity:ro --env-file="
            # double quotes not added, because the command already contains
            # double quotes
            assert do_match "$message" "dummyide:0.0.1 -c \"echo aaa\""
          end
        end
      end
    end
  end
end
