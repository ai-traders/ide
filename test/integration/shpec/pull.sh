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
        docker rmi alpine:3.5
        message=$(cd test/docker/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that command to be used is: pull"
          assert do_match "$message" "ide_command: pull"
        end
        it "pulls docker image"
          assert do_match "$message" "Pulling docker image: alpine:3.5"
        end
      end
      describe "with custom idefile"
        # clean up before test, if there is no such image, docker will
        # return error, ignore that
        docker rmi alpine:3.5
        message=$(IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull --idefile test/docker/publicide-usage/Idefile)
        exit_status="$?"
        it "exits with status 0"
          assert equal "$exit_status" "0"
        end
        it "informs that command to be used is: pull"
          assert do_match "$message" "ide_command: pull"
        end
        it "pulls docker image"
          assert do_match "$message" "Pulling docker image: alpine:3.5"
        end
      end
    end
    describe "when run with '--command pull' and docker image exists locally"
      message=$(cd test/docker/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      message=$(docker images | grep alpine)
      exit_status="$?"
      it "docker image is pulled"
        assert equal "$exit_status" "0"
        assert do_match "$message" "alpine"
        assert do_match "$message" "3.5"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"; version 1 of docker-compose file'
    describe "when run with '--command pull' and docker image does not exist locally"
      # clean up before test, if there is no such image, docker will
      # return error, ignore that
      docker rmi alpine:3.5
      message=$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      message=$(docker images | grep alpine)
      exit_status="$?"
      it "docker image is pulled"
        assert equal "$exit_status" "0"
        assert do_match "$message" "alpine"
        assert do_match "$message" "3.5"
      end
    end
    describe "when run with '--command pull' and docker image exists locally"
      message=$(cd test/docker-compose/publicide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      message=$(docker images | grep alpine)
      exit_status="$?"
      it "docker image is pulled"
        assert equal "$exit_status" "0"
        assert do_match "$message" "alpine"
        assert do_match "$message" "3.5"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"; version 2 of docker-compose file'
    describe "when run with '--command pull' and docker image does not exist locally"
      # clean up before test, if there is no such image, docker will
      # return error, ignore that
      docker rmi alpine:3.5
      message=$(cd test/docker-compose/publicide-v2-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      message=$(docker images | grep alpine)
      exit_status="$?"
      it "docker image is pulled"
        assert equal "$exit_status" "0"
        assert do_match "$message" "alpine"
        assert do_match "$message" "3.5"
      end
    end
    describe "when run with '--command pull' and docker image exists locally"
      message=$(cd test/docker-compose/publicide-v2-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} --command pull)
      exit_status="$?"
      it "exits with status 0"
        assert equal "$exit_status" "0"
      end
      it "informs that command to be used is: pull"
        assert do_match "$message" "ide_command: pull"
      end
      message=$(docker images | grep alpine)
      exit_status="$?"
      it "docker image is pulled"
        assert equal "$exit_status" "0"
        assert do_match "$message" "alpine"
        assert do_match "$message" "3.5"
      end
    end
  end
end
