#!/bin/bash

###########################################################################
# This file ensures files are mapped from /ide/identity into /home/ide.
# Fails if any required secret or configuration file is missing.
###########################################################################

# This is the directory we expect to be mounted as docker volume.
# From that directory we mapt configuration and secrets files.
ide_identity="/ide/identity"

# 1st file we need
# at least this is needed:
# StrictHostKeyChecking no
if [ ! -f "$ide_identity/.ssh/config" ]; then
  echo "$ide_identity/.ssh/config does not exist"
  exit 1;
fi
mkdir -p /home/ide/.ssh
touch /home/ide/.ssh/config
cat $ide_identity/.ssh/config | sed -E 's/IdentityFile.*/IdentityFile \/home\/ide\/.ssh\/id_rsa/g' >> /home/ide/.ssh/config

# actually, a better idea, would be to generate /home/ide/.ssh/config here
# instead of copying it; same for other configs which need user name or other
# user specific variables, e.g. knife.rb for chef

# 2nd file we need
if [ ! -f "$ide_identity/.ssh/id_rsa" ]; then
  echo "$ide_identity/.ssh/id_rsa does not exist"
  exit 1;
fi
cp $ide_identity/.ssh/id_rsa /home/ide/.ssh/

# 3rd: not obligatory configuration file
if [ -f "$ide_identity/.gitconfig" ]; then
  cp "$ide_identity/.gitconfig" /home/ide/
fi

# 4rd file we need; in order to ensure that after bash login, the ide user
# is in /ide/work. Not obligatory but shortens end user's commands.
touch /home/ide/.profile
echo "cd /ide/work" > /home/ide/.profile
