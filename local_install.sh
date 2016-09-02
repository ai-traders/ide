#!/bin/bash -ex

# Installs IDE.

# Absolute path to this script
script_path=$(readlink -f "$BASH_SOURCE")
# Absolute path to a directory this script is in
script_dir=$(dirname "${script_path}")

cp "${script_dir}/ide" /usr/bin/ide
cp "${script_dir}/ide_functions" /usr/bin/ide_functions
cp "${script_dir}/ide_version" /usr/bin/ide_version
chmod 755 /usr/bin/ide
chmod 755 /usr/bin/ide_functions
chmod 755 /usr/bin/ide_version
