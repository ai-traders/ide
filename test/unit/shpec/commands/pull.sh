describe "ide command: pull"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    describe "when run with '--command pull --dryrun'"
      message="$(cd test/docker/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
    describe "when run with '-c pull --dryrun'"
      message="$(cd test/docker/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} -c pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe "when run with '--command pull --dryrun'"
      message="$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
    describe "when run with '-c pull --dryrun'"
      message="$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} -c pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
    describe "when run with '-c pull --dryrun' and using v2 of docker-compose file"
      message="$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} -c pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
  end
end
