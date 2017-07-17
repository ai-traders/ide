#!/bin/bash

###########################################################################
# A file to keep any bash variables for IDE to work.
# Override this file to change the below variables or add any new files in
# /etc/ide.d/variables/ directory
###########################################################################

# ide_work is the directory mounted as docker volume inside a docker container.
# From that directory we can infer uid and gid.
export ide_work="${IDE_WORK_INNER}"
export ide_home="/home/ide"
export ide_identity="/ide/identity"
export owner_username="ide"
export owner_groupname="ide"
