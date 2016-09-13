describe "ide --pull_only"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    it "returns 0; prints all the ide options"
      message="$(${IDE_PATH} --help)"
      assert equal "$?" "0"
      assert do_match "$message" "Usage:"
      assert do_match "$message" " --help"
      assert do_match "$message" " --version"
      assert do_match "$message" " --idefile"
      assert do_match "$message" " --dryrun"
      assert do_match "$message" " --pull_only"
      assert do_match "$message" " --force_not_interactive"
      assert do_match "$message" " --not_i"
    end
  end
end
