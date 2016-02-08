#!/bin/bash

###########################################################################
# This file is an init script to properly start docker container.
###########################################################################

set -e

/usr/bin/ide-setup-identity.sh
/usr/bin/ide-fix-uid-gid.sh

source /etc/docker_metadata.txt

if [ -t 0 ] ; then
    # interactive shell
    echo "ide init finished (interactive shell), using ${this_image_name}:${this_image_tag}"

    # No "set -e" here, you don't want to be logged out when sth returns not 0
    # in interactive shell.
    set +e
else
    # not interactive shell
    echo "ide init finished (not interactive shell), using ${this_image_name}:${this_image_tag}"
    set -e
fi

sudo -E -H -u ide /bin/bash -lc "$@"
