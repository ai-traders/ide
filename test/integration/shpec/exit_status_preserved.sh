describe "ide preserves exit status"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    describe 'when exit 164 in docker container'
      it "returns 164"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        docker rmi alpine:3.4
        message="$(cd test/docker/dummyide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} 'echo abc && exit 164')"
        assert equal "$?" "164"
        assert do_match "$message" "abc"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when exit 164 in docker container'
      it "returns 164"
        message="$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'echo abc && exit 164')"
        assert equal "$?" "164"
        assert do_match "$message" "abc"
      end
    end
  end
end
