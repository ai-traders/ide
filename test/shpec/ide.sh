describe "commandline options"
  IDE_PATH=$(readlink -f "./ide")

  describe "--version"
    it "outputs the current version number"
      message="$(${IDE_PATH} --version)"
      assert equal "$message" "${IDE_PATH} version 0.0.1"
    end
  end
  describe "--group"
    it "exits 1, groups are not supported"
      message="$(${IDE_PATH} --group \"\")"
      assert equal "$?" "1"
      assert equal "$message" "groupnames other than default are not supported"
    end
  end
  describe "--idefile"
    it "exits 1, if zero-length string set"
      message="$(${IDE_PATH} --idefile)"
      assert equal "$?" "1"
      assert equal "$message" "idefile not specified"
    end
    it "exits 1, if not zero-length string set, but the file does not exist"
      message="$(${IDE_PATH} --idefile aa --dryrun)"
      assert equal "$?" "1"
      assert equal "$message" "idefile: aa does not exist"
    end
    it "exits 0, if not zero-length string set and the file exists"
      message="$(${IDE_PATH} --idefile examples/gitide-usage/Idefile --dryrun)"
      assert equal "$?" "0"
    end
  end
end
