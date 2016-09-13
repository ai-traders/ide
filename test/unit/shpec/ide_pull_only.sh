describe "ide --pull_only"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    describe 'when --dryrun and --pull_only is set'
      it "returns 0; does nothing"
        message="$(cd test/docker/publicide-usage && ${IDE_PATH} --pull_only --dryrun)"
        assert equal "$?" "0"
        assert equal "$message" ""
      end
    end
    describe 'when --pull_only is set and docker image does not exist locally'
      it "returns 0; pulls docker image"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        docker rmi alpine:3.4
        message="$(cd test/docker/publicide-usage && ${IDE_PATH} --pull_only)"
        assert equal "$?" "0"
        assert do_match "$message" "Pulling docker image: alpine:3.4"
      end
    end
    describe 'when --pull_only is set and docker image exists locally'
      it "returns 0; says there is no need to pull docker image"
        message="$(cd test/docker/publicide-usage && ${IDE_PATH} --pull_only)"
        assert equal "$?" "0"
        assert do_match "$message" "Image is up to date for alpine:3.4"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when --dryrun and --pull_only is set'
      it "returns 0; does nothing"
        message="$(cd test/docker-compose/publicide-usage && ${IDE_PATH} --pull_only --dryrun)"
        assert equal "$?" "0"
        assert equal "$message" ""
      end
    end
    describe 'when --pull_only is set and docker image does not exist locally'
      it "returns 0; pulls docker image"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        docker rmi alpine:3.4
        message="$(cd test/docker-compose/publicide-usage && ${IDE_PATH} --pull_only)"
        assert equal "$?" "0"
        assert do_match "$message" "Downloaded newer image for alpine:3.4"
      end
    end
    describe 'when --pull_only is set and docker image exists locally'
      it "returns 0; says there is no need to pull docker image"
        message="$(cd test/docker-compose/publicide-usage && ${IDE_PATH} --pull_only)"
        assert equal "$?" "0"
        assert do_match "$message" "Image is up to date for alpine:3.4"
      end
    end
  end
end
