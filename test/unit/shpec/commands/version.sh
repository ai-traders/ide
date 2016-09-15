describe "ide command: version"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe "when run with '--command version'"
    message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command version)"
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs about ide version"
      assert do_match "$message" "ide version "
    end
  end
  describe "when run without '-c version'"
    message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c version)"
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs about ide version"
      assert do_match "$message" "ide version "
    end
  end
  describe "when run with '-c version bla abc 1'"
    message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} -c version bla abc 1)"
    exit_status="$?"
    it "exits with status 0"
      assert equal "$exit_status" "0"
    end
    it "informs about ide version, ignores the rest of parameters"
      assert do_match "$message" "ide version "
    end
  end
end
