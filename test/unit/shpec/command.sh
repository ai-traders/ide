describe "ide command"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")
  # Tests that IDE can be run with: --command or -c option or
  # without any command option (using default command).
  # Warn: this uses the main Idefile.

  describe "when run without --command or --c option"
    message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} --dryrun)"
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs that ide command is: run"
      assert do_match "$message" "ide_command: run"
    end
  end
  describe "when run explicitly with default command"
    describe "when run with '--command run'"
      message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command run --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is: run"
        assert do_match "$message" "ide_command: run"
      end
    end
    describe "when run with '-c run'"
      message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c run --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is: run"
        assert do_match "$message" "ide_command: run"
      end
    end
  end
  describe "when run with some valid, not default command"
    describe "when run with '--command pull'"
      message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is: pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
    describe "when run with '-c pull'"
      message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c pull --dryrun)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that ide command is: pull"
        assert do_match "$message" "ide_command: pull"
      end
    end
  end
  describe "when run with some invalid command"
    describe "when run with '--command bla'"
      message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command bla --dryrun)"
      exit_status="$?"
      it "exits with status 1"
        assert equal "$exit_status" "1"
      end
      it "informs about unsupported IDE command"
        assert do_match "$message" "Unsupported IDE command: bla"
      end
    end
    describe "when run with '-c bla'"
      message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c bla --dryrun)"
      exit_status="$?"
      it "exits with status 1"
        assert equal "$exit_status" "1"
      end
      it "informs about unsupported IDE command"
        assert do_match "$message" "Unsupported IDE command: bla"
      end
    end
  end
end
