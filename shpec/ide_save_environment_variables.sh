# describe "commandline options"
#   # make absolute path out of relative
#   IDE_PATH=$(readlink -f "./ide_functions")
#   env_file = 'tmp_env'
#
#   describe 'get_env_vars_file_name'
#     it "returns file name"
#       message="source ${IDE_PATH} && save_environment_variables #{env_file}"
#       assert equal "$message" "/tmp/ide/environment-"
#     end
#   end
# end
