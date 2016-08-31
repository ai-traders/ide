#!/bin/bash

# This script helps to make an ide docker image.
# See entrypoint.sh too.

# Absolute path to this script
script_path=$(readlink -f "$BASH_SOURCE")
# Absolute path to a directory this script is in
script_dir=$(dirname "${script_path}")

cp "${script_dir}/entrypoint.sh" /usr/bin/entrypoint.sh
mkdir /etc/ide.d
# 50 is because user may want to do things before and after home and work
# directories ownership was fixed. Also user may wish to delete/replace this script.
cp "${script_dir}/50-ide-fix-uid-gid.sh" /etc/ide.d/50-ide-fix-uid-gid.sh


# Add ide user with some random password. Since the password is never needed,
# do not even print it.
random_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!|' | fold -w 8 | head -n 1)

# for Ubuntu:
# cmd not found on alpine linux
groupadd --gid 1000 ide
# cmd not found on alpine linux
useradd --home-dir /home/ide --uid 1000 --gid 1000 --shell /bin/bash --password "${random_password}" ide
usermod -a -G ide ide

# for Alpine Linux:
# echo "${random_password}" | adduser -h /home/ide -u 1000 -s /bin/bash ide
# addgroup -g 1000 ide # returns 1 but creates group: ide
# addgroup ide ide # adds user: ide to group: ide

mkdir /home/ide
chown ide:ide /home/ide
