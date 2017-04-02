describe "ide command: help"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe "when run with '--command help'"
    message=$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command help)
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs about ide usage"
      assert do_match "$message" "Usage:"
      assert do_match "$message" "run"
      assert do_match "$message" "pull"
      assert do_match "$message" "help"
      assert do_match "$message" "version"
      assert do_match "$message" "--idefile"
      assert do_match "$message" "--dryrun"
      assert do_match "$message" "--force_not_interactive"
      assert do_match "$message" "--not_i"
      assert do_match "$message" "--no_rm"
    end
  end
  describe "when run with '-c help'"
    message=$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c help)
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs about ide usage"
      assert do_match "$message" "Usage:"
    end
  end
  describe "when run with '-c help bla abc 1'"
    message=$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c help bla abc 1)
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs about ide usage, ignores the rest of parameters"
      assert do_match "$message" "Usage:"
    end
  end
end
