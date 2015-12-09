#!/bin/bash -ex

# if ide is going to be split into more files, see how this is done:
# https://github.com/rylnd/shpec/blob/master/install.sh

TMPDIR=${TMPDIR:-/tmp}
cd $TMPDIR
sudo wget --quiet http://gitlab.ai-traders.com/lab/ide/raw/master/ide -O /usr/bin/ide
chmod 755 /usr/bin/ide
