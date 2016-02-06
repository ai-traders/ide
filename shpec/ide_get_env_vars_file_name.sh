# describe "commandline options"
#   # make absolute path out of relative
#   IDE_PATH=$(readlink -f "./ide_functions")
#
#   describe 'get_env_vars_file_name'
#     it "returns file name"
#       message="source ${IDE_PATH} && get_env_vars_file_name"
#       assert equal "$message" "/tmp/ide/environment-"
#     end
#   end
# end
