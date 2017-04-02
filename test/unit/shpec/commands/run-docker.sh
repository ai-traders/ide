describe "ide command: run"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    describe 'idefile verification'
      describe 'when IDE_DOCKER_IMAGE not set'
        message=$(${IDE_PATH} --idefile test/docker/image-not-set-ide-usage/Idefile --dryrun some_command)
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
        message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)
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
        message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --not_i)
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
        message=$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --not_i echo sth)
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
        message=$(cd ${publicide_path} && ${IDE_PATH} --no_rm --dryrun)
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
  end
end
