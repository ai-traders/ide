describe "ide --force_not_interactive"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    describe 'when --dryrun and --not_i is set; ide cmd is set'
      it "returns 0; does nothing"
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --not_i echo sth)"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: true"
        assert do_match "$message" "run_interactively: false"
        assert do_match "$message" "dummyide:0.0.1 \"echo sth\""
        assert do_not_match "$message" " -ti"
      end
    end
    describe 'when --dryrun and --force_not_interactive is set; ide cmd is set'
      it "returns 0; does nothing"
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive echo sth)"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: true"
        assert do_match "$message" "run_interactively: false"
        assert do_match "$message" "dummyide:0.0.1 \"echo sth\""
        assert do_not_match "$message" " -ti"
      end
    end
    describe 'when --dryrun and --force_not_interactive is set; ide cmd is not set'
      it "returns 0; does nothing"
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: true"
        assert do_match "$message" "run_interactively: false"
        assert do_not_match "$message" " -ti"
      end
    end
    describe 'when --force_not_interactive is set; ide cmd is set'
      it "returns 0; runs not interactively"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'bash --version && pwd')"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: false"
        assert do_match "$message" "run_interactively: false"
        assert do_not_match "$message" " -ti"
        assert do_match "$message" "dummyide:0.0.1 \"bash --version && pwd \""
        assert do_match "$message" "GNU bash, version 4.3"
        assert do_match "$message" "/ide/work"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when --dryrun and --force_not_interactive is set; ide cmd is set'
      it "returns 0; does nothing"
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive echo sth)"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: true"
        assert do_match "$message" "run_interactively: false"
        assert do_match "$message" " -T"
        assert do_match "$message" "default \"echo sth\""
      end
    end
    describe 'when --dryrun and --force_not_interactive is set; ide cmd is not set'
      it "returns 0; does nothing"
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun --force_not_interactive)"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: true"
        assert do_match "$message" "run_interactively: false"
        assert do_match "$message" " -T"
      end
    end
    describe 'when --force_not_interactive is set; ide cmd is set'
      it "returns 0; does nothing"
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'bash --version && pwd')"
        assert equal "$?" "0"
        assert do_match "$message" "dryrun: false"
        assert do_match "$message" "run_interactively: false"
        assert do_match "$message" " -T"
        assert do_match "$message" "default \"bash --version && pwd \""
        assert do_match "$message" "GNU bash, version 4.3"
        assert do_match "$message" "/ide/work"
      end
    end
  end
end
