#!/bin/bash -ex

# Installs IDE.

# If ide is going to be split into more files, see how this is done:
# https://github.com/rylnd/shpec/blob/master/install.sh

TMPDIR=${TMPDIR:-/tmp}
cd $TMPDIR
# wget --quiet option is not available on Alpine, but wget -q is on both:
# Alpine and Ubuntu
wget -q https://raw.githubusercontent.com/ai-traders/ide/master/ide -O /usr/bin/ide
wget -q https://raw.githubusercontent.com/ai-traders/ide/master/ide_functions -O /usr/bin/ide_functions
wget -q https://raw.githubusercontent.com/ai-traders/ide/master/ide_version -O /usr/bin/ide_version
chmod 755 /usr/bin/ide
chmod 755 /usr/bin/ide_functions
chmod 755 /usr/bin/ide_version
