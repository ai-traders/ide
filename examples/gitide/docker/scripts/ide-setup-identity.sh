#!/bin/bash

###########################################################################
# This file ensures files are mapped from ide_identity into ide_home.
# Fails if any required secret or configuration file is missing.
###########################################################################

# This is the directory we expect to be mounted as docker volume.
# From that directory we mapt configuration and secrets files.
ide_identity="/ide/identity"
ide_home="/home/ide"
ide_work="/ide/work"

# 1st directory we need, copy it with all the secrets, particulary id_rsa
if [ ! -d "${ide_identity}/.ssh" ]; then
  echo "${ide_identity}/.ssh does not exist"
  exit 1;
fi
if [ ! -f "${ide_identity}/.ssh/id_rsa" ]; then
  echo "${ide_identity}/.ssh/id_rsa does not exist"
  exit 1;
fi
cp -r "${ide_identity}/.ssh" "${ide_home}"

# 2nd we need to ensure that ${ide_home}/.ssh/config contains at least:
# StrictHostKeyChecking no
echo "StrictHostKeyChecking no
UserKnownHostsFile /dev/null
ForwardAgent yes
Host git.ai-traders.com
User git
Port 2222
IdentityFile ${ide_home}/.ssh/id_rsa
" > "${ide_home}/.ssh/config"

# 3rd: not obligatory configuration file
if [ -f "${ide_identity}/.gitconfig" ]; then
  cp "${ide_identity}/.gitconfig" "${ide_home}"
fi

# 4rd file we need; in order to ensure that after bash login, the ide user
# is in /ide/work. Not obligatory but shortens end user's commands.
# Do not copy it from $IDE_IDENTITY, because it may reference sth not installed in
# this docker image.
touch "${ide_home}/.profile"
echo "cd ${ide_work}" > "${ide_home}/.profile"
