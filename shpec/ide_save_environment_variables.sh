describe "save_environment_variables"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")
  env_file='tmp_env'

  describe "when incorrectly initialized -- returns 1"
    it "returns 1 if env_file not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && save_environment_variables")"
      assert equal "$?" "1"
      assert do_match "$message" "error: env_file not specified"
    end

    it "returns 1 if blacklisted_variables_from_user not set"
      message="$(/bin/bash -c "source ${IDE_PATH} && save_environment_variables ${env_file}")"
      assert equal "$?" "1"
      assert do_match "$message" "error: blacklisted_variables_from_user not specified"
    end
  end

  describe "when correctly initialized -- returns 0 and saves correctly to file"
    it "no blacklisted_variables_from_user"
      message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 CDE=246 save_environment_variables ${env_file} \" \"")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert match "$file_contents" "ABC=123"
      assert match "$file_contents" "CDE=246"
    end
    it "blacklisted_variables_from_user set to ABC,ZZZ and ABC=123 CDE=246 set (normal envs only)"
      message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 CDE=246 save_environment_variables ${env_file} ABC,ZZZ")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert match "$file_contents" "IDE_ABC=123"
      assert match "$file_contents" "CDE=246"
      assert no_match "$file_contents" "IDE_CDE=246"
      assert no_match "$file_contents" "ZZZ"
    end
    it "blacklisted_variables_from_user set to ABC,ZZZ and ABC=123 IDE_ABC=333 CDE=246 set (normal envs and IDE_)"
      message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 IDE_ABC=333 CDE=246 save_environment_variables ${env_file} ABC,ZZZ")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert match "$file_contents" "IDE_ABC=333"
      assert match "$file_contents" "CDE=246"
      assert no_match "$file_contents" "ABC=123"
      assert no_match "$file_contents" "IDE_CDE=246"
      #none_equal_from_array "$file_contents" "ZZZ"
      for file_line in $file_contents ; do
          assert unequal "$file_line" "ZZZ"
      done
    end
    it "blacklisted_variables_from_user set to ABC,ZZZ and IDE_ABC=333 CDE=246 set (IDE_ env only)"
      message="$(/bin/bash -c "source ${IDE_PATH} && IDE_ABC=333 CDE=246 save_environment_variables ${env_file} ABC,ZZZ")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert match "$file_contents" "IDE_ABC=333"
      assert match "$file_contents" "CDE=246"
      assert no_match "$file_contents" "ABC=123"
      assert no_match "$file_contents" "IDE_CDE=246"
      assert no_match "$file_contents" "ZZZ"
    end
    it "blacklisted_variables_from_user set to ABC,ZZZ* and IDE_ABC=333 CDE=246 ZZZ=111 set"
      message="$(/bin/bash -c "source ${IDE_PATH} && ABC=123 CDE=246 ZZZ=111 ZZZZ=1111 save_environment_variables ${env_file} ABC,ZZZ*")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert match "$file_contents" "IDE_ABC=123"
      assert match "$file_contents" "CDE=246"
      assert match "$file_contents" "IDE_ZZZ=111"
      assert match "$file_contents" "IDE_ZZZZ=1111"
      assert no_match "$file_contents" "IDE_CDE=246"
    end
  end
end
