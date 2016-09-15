describe "ide --no_rm"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide")
  publicide_path="test/docker/publicide-usage"
  iderc="${publicide_path}/iderc"

  publicide_path_dc="test/docker-compose/publicide-usage"

  describe 'when IDE_DRIVER="docker"'
    describe 'when --dryrun and --no_rm is set'
      it "returns 0; creates iderc, does not create docker container"
        rm -rf "${iderc}"
        message="$(cd ${publicide_path} && ${IDE_PATH} --no_rm --dryrun)"
        assert equal "$?" "0"
        assert do_not_match "$message" "--rm"
        rm -rf "${iderc}"
      end
    end
    describe 'when --no_rm is set'
      it "returns 0; creates docker container and does not remove it"
        rm -rf "${iderc}"
        message="$(cd ${publicide_path} && IDE_LOG_LEVEL=debug ${IDE_PATH} --no_rm whoami)"
        assert equal "$?" "0"
        assert do_not_match "$message" "--rm"

        # this is how to get the name of the container
        container_name="$(cat ${iderc})"
        assert do_match "$container_name" "ide-publicide-usage"

        # container is running? should be not removed and be stopped
        assert do_match $(docker inspect  --format {{.State.Running}} ${container_name}) "false"
        docker rm ${container_name}
        rm -rf "${iderc}"
      end
    end
  end
  describe 'when IDE_DRIVER="docker-compose"'
    describe 'when --dryrun and --no_rm is set'
      it "returns 1; not implemented"
        message="$(cd ${publicide_path_dc} && ${IDE_PATH} --no_rm --dryrun)"
        assert equal "$?" "1"
        assert do_match "$message" "Not implemented feature: '--no_rm' for driver: docker-compose"
      end
    end
  end
end
