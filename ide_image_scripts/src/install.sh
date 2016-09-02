#!/bin/bash

# This script helps to make an ide docker image.
# It installs:
# * ide scripts into /etd/ide.d/scripts/
# * ide variables into /etd/ide.d/variables/
# * ide entrypoint into /usr/bin/entrypoint.sh
# * adds ide linux user and group
# Works on Ubuntu/Debian/Alpine.

# Absolute path to this script
script_path=$(readlink -f "$BASH_SOURCE")
# Absolute path to a directory this script is in
script_dir=$(dirname "${script_path}")

cp "${script_dir}/entrypoint.sh" /usr/bin/entrypoint.sh
mkdir /etc/ide.d
mkdir /etc/ide.d/scripts
mkdir /etc/ide.d/variables
# 50 is because user may want to do things before and after home and work
# directories ownership was fixed. Also user may wish to delete/replace this script.
cp "${script_dir}/50-ide-fix-uid-gid.sh" /etc/ide.d/scripts/50-ide-fix-uid-gid.sh
cp "${script_dir}/variables.sh" /etc/ide.d/variables/01-variables.sh

# Add ide user and group
groupadd --gid 1000 ide
useradd --home-dir /home/ide --uid 1000 --gid 1000 --shell /bin/bash ide
usermod -a -G ide ide # adds user: ide to group: ide

mkdir -p /home/ide
chown ide:ide /home/ide
