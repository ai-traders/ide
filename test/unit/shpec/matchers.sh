describe "matchers"
  # make absolute path out of relative
  do_match_file=$(readlink -f "./shpec/matchers/do_match.sh")

  describe "do_match"
    it "aaa matches aaa"
      assert do_match "aaa" "aa"
    end
    it "partial matches partially"
      assert do_match "partially" "partial"
    end
    it "\"-ti\" matches \"-ti\""
      assert do_match "\"-ti\"" "\"-ti\""
    end
    it "\"-ti\" matches \"ti -rm\""
      assert do_match "-ti -rm" "-ti"
    end
  end
