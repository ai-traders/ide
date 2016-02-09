#!/bin/bash

###########################################################################
# This file ensures that ide user has the same uid and gid as
# /ide/work directory.
# Used as fix-uid-gid solution in docker, almost copied from:
# https://github.com/tomzo/docker-uid-gid-fix/blob/master/fix-uid-gid.sh
###########################################################################

# This is the directory we expect to be mounted as docker volume.
# From that directory we know uid and gid.
ide_home="/home/ide"
ide_work="/ide/work"
owner_username="ide"
owner_groupname="ide"

if [ -z "$ide_work" ]; then
  echo "ide_work not specified"
  exit 1;
fi

if [ -z "$ide_home" ]; then
  echo "ide_home not specified"
  exit 1;
fi

if [ -z "$owner_username" ]; then
  echo "Username not specified"
  exit 1;
fi
if [ -z "$owner_groupname" ]; then
  echo "Groupname not specified"
  exit 1;
fi
if [ ! -d "$ide_work" ]; then
  echo "$ide_work does not exist, expected to be mounted as docker volume"
  exit 1;
fi

ret=false
getent passwd "$owner_username" >/dev/null 2>&1 && ret=true
if ! $ret; then
    echo "User $owner_username does not exist"
    exit 1;
fi

ret=false
getent passwd "$owner_groupname" >/dev/null 2>&1 && ret=true
if ! $ret; then
    echo "Group $owner_groupname does not exist"
    exit 1;
fi

newuid=$(ls --numeric-uid-gid -d "$ide_work" | awk '{ print $3 }')
newgid=$(ls --numeric-uid-gid -d "$ide_work" | awk '{ print $4 }')

usermod -u "$newuid" "$owner_username"
groupmod -g "$newgid" "$owner_groupname"
# Might be needed if the image has files which should be owned by
# this user and group. When we know more about user and group, then
# this find might be at smaller scope.
# In this case, image has only /home/ide owned by 1000
# find /home/ide -user 1000 -exec chown -h $newuid {} \;
# find /home/ide -group 1000 -exec chgrp -h $newgid {} \;
chown $newuid:$newgid -R "$ide_home"

# do not chown the /ide/work directory, it already has proper uid and gid,
# besides, when /ide/work is very big, chown would take much time
