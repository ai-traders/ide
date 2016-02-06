describe "commandline options"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")
  env_file='tmp_env'

  describe 'preserves correct variables'
    it "returns file name"
      message="$(/bin/bash -c "source ${IDE_PATH} && DUMMY=123 save_environment_variables ${env_file}")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert match "$file_contents" "DUMMY=123"
      assert match "$message" "aaab"
    end
  end
end
