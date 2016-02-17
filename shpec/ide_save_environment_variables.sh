describe "save_environment_variables"
  # make absolute path out of relative
  IDE_PATH=$(readlink -f "./ide_functions")
  env_file='tmp_env'
  real_blacklisted="BASH*,HOME,USERNAME,USER,LOGNAME,PATH,TERM,SHELL,MAIL,SUDO_*,WINDOWID,SSH_*,SESSION_*,GEM_HOME,GEM_PATH,GEM_ROOT,HOSTNAME,HOSTTYPE,IFS,PPID,PWD,OLDPWD"

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
    it "returns 1 if blacklisted_variables_from_user set to WORK"
      message="$(/bin/bash -c "source ${IDE_PATH} && save_environment_variables ${env_file} WORK")"
      assert equal "$?" "1"
      assert do_match "$message" "error: blacklisted WORK environment variable"
    end
    it "returns 1 if blacklisted_variables_from_user set to IDENTITY"
      message="$(/bin/bash -c "source ${IDE_PATH} && save_environment_variables ${env_file} IDENTITY")"
      assert equal "$?" "1"
      assert do_match "$message" "error: blacklisted IDENTITY environment variable"
    end
    it "returns 1 if blacklisted_variables_from_user set to ABC,DRIVER,AAA"
      message="$(/bin/bash -c "source ${IDE_PATH} && save_environment_variables ${env_file} ABC,DRIVER,AAA*")"
      assert equal "$?" "1"
      assert do_match "$message" "error: blacklisted DRIVER environment variable"
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
      assert no_match "$file_line" "ZZZ"
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
      assert do_match "$file_contents" "IDE_ABC=123" # ^IDE_ABC=123 does not match, because IDE_ABC is in the first line?
      assert do_match "$file_contents" "^CDE=246"
      assert do_match "$file_contents" "^IDE_ZZZ=111"
      assert do_match "$file_contents" "^IDE_ZZZZ=1111"
      assert no_match "$file_contents" "^IDE_CDE=246"
    end
    # This test shall not pass if you only set HOME and not IDE_HOME while
    # IDE_HOME is set. Then, IDE_HOME has stronger precedence than HOME and the
    # value of IDE_HOME will be saved under IDE_HOME name.
    # However, if IDE_HOME was not set and you only set here HOME, then
    # the value of HOME will be saved under IDE_HOME name.
    # Same for any other IDE_* variables.
    it "real blacklisted_variables and almost real environment"
      message="$(/bin/bash -c "source ${IDE_PATH} && IDE_SSH_AGENT_PID=29 \
GEM_HOME=/home/ewa/.chefdk/gem/ruby/2.1.0 GLADE_PIXMAP_PATH=: TERM=xterm \
SHELL=/bin/bash XDG_MENU_PREFIX=xfce- VAGRANT_DEFAULT_PROVIDER=openstack \
OS_REGION_NAME=RegionOne WINDOWID=52428804 IDE_HOME=/home/someone USER=someone \
save_environment_variables ${env_file} \"${real_blacklisted}\"")"
      assert equal "$?" "0"
      file_contents=$(cat ${env_file})
      assert do_match "$file_contents" "^IDE_SSH_AGENT_PID=29"
      assert no_match "$file_contents" "^SSH_AGENT_PID"
      assert do_match "$file_contents" "IDE_GEM_HOME"
      assert no_match "$file_contents" "^GEM_HOME"
      assert do_match "$file_contents" "IDE_SHELL"
      assert no_match "$file_contents" "^SHELL"
      assert do_match "$file_contents" "^OS_REGION_NAME=RegionOne"
      assert do_match "$file_contents" "^IDE_HOME=/home/someone"
      assert no_match "$file_contents" "^HOME=/home/someone"
      assert do_match "$file_contents" "^IDE_USER="
      assert no_match "$file_contents" "^USER="
    end
  end
end
