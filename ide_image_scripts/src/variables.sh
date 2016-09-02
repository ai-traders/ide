#!/bin/bash

###########################################################################
# A file to keep any bash variables for IDE to work.
###########################################################################

# This is the directory we expect to be mounted as docker volume.
# From that directory we know uid and gid.
export ide_work="/ide/work"
export ide_home="/home/ide"
export ide_identity="/ide/identity"
export owner_username="ide"
export owner_groupname="ide"

# Override this file to change the above variables or add any new like:
# export this_image_name="ideide"
# export this_image_tag="1.0.0"
