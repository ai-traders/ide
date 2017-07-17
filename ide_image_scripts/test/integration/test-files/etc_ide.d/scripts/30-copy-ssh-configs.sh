#!/bin/bash

###########################################################################
# This file ensures that files are mapped from ide_identity
# into ide_home. Fails if any required secret or configuration file is missing.
###########################################################################

# 1st directory we need, copy it with all the secrets, particulary id_rsa
if [ ! -d "${ide_identity}/.ssh" ]; then
  echo "${ide_identity}/.ssh does not exist"
  exit 1;
fi
if [ ! -f "${ide_identity}/.ssh/id_rsa" ]; then
  echo "${ide_identity}/.ssh/id_rsa does not exist"
  exit 1;
fi
cp -ar "${ide_identity}/.ssh" "${ide_home}"

# 2nd we need to ensure that ${ide_home}/.ssh/config contains at least:
# StrictHostKeyChecking no
echo "StrictHostKeyChecking no
UserKnownHostsFile /dev/null
" > "${ide_home}/.ssh/config"
