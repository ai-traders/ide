describe "ide command: run preserves exit status"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")

  describe 'when IDE_DRIVER="docker"'
    describe 'when exit 164 in docker container'
      it "returns 164"
        message=$(cd test/docker/example-ide-usage && IDE_LOG_LEVEL=debug ${IDE_PATH} 'echo abc && exit 164')
        exit_status="$?"
        it "exits with status 164"
          assert equal "$exit_status" "164"
        end
        it "docker run command returns 'abc'"
          assert do_match "$message" "abc"
        end
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when exit 164 in docker container'
      it "returns 164"
        message=$(cd test/docker-compose/default && IDE_LOG_LEVEL=debug ${IDE_PATH} --force_not_interactive 'echo abc && exit 164')
        exit_status="$?"
        it "exits with status 164"
          assert equal "$exit_status" "164"
        end
        it "docker-compose run command returns 'abc'"
          assert do_match "$message" "abc"
        end
      end
    end
  end
end
