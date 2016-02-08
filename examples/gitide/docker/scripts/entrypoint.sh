#!/bin/bash

###########################################################################
# This file is an init script to properly start docker container.
###########################################################################

set -e

/usr/bin/ide-setup-identity.sh
/usr/bin/ide-fix-uid-gid.sh

if [ -t 0 ] ; then
    # interactive shell
    echo "ide init finished (interactive shell), using gitide"

    # No "set -e" here, you don't want to be logged out when sth returns not 0
    # in interactive shell.
    set +e
else
    # not interactive shell
    echo "ide init finished (not interactive shell), using gitide"
    set -e
fi

sudo -E -H -u ide /bin/bash -lc "$@"
