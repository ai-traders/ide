describe "ide command: pull"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")
  # It is important that those tests test for use case when
  # * no other options than --command pull are set
  # * other options than --command pull are set

  describe 'when IDE_DRIVER="docker"'
    describe "when run with '--command pull' and docker image does not exist locally"
      describe "with default idefile"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        docker rmi alpine:3.4
        message="$(cd test/docker/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that command to be used is: pull"
          assert do_match "$message" "ide_command: pull"
        end
        it "pulls docker image"
          assert do_match "$message" "Pulling docker image: alpine:3.4"
        end
      end
      describe "with custom idefile"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        docker rmi alpine:3.4
        message="$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull --idefile test/docker/publicide-usage/Idefile)"
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that command to be used is: pull"
          assert do_match "$message" "ide_command: pull"
        end
        it "pulls docker image"
          assert do_match "$message" "Pulling docker image: alpine:3.4"
        end
      end
    end
    describe "when run with '--command pull' and docker image exists locally"
      message="$(cd test/docker/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      it "informs there is no need to pull docker image"
        assert do_match "$message" "Image is up to date for alpine:3.4"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe "when run with '--command pull' and docker image does not exist locally"
      # clean up before test, if there is no such image, docker will
      # return error, ignore that
      docker rmi alpine:3.4
      message="$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      it "pulls docker image"
        assert do_match "$message" "Downloaded newer image for alpine:3.4"
      end
    end
    describe "when run with '--command pull' and docker image exists locally"
      message="$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)"
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      it "informs there is no need to pull docker image"
        assert do_match "$message" "Image is up to date for alpine:3.4"
      end
    end
  end
end
