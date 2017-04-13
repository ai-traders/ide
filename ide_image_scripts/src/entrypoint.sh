#!/bin/bash

###########################################################################
# This file is an init script to properly start ide docker container.
###########################################################################

set -e

# source any additional scripts with environment variables
for SCRIPT in /etc/ide.d/variables/* ; do
	if [ -f $SCRIPT ] ; then
		chmod +x $SCRIPT
		source $SCRIPT
	fi
done
# run any additional scripts to setup custom configuration files or secrets
# or source any files or wait for linux daemons
for SCRIPT in /etc/ide.d/scripts/* ; do
	if [ -f $SCRIPT ] ; then
		chmod +x $SCRIPT
		$SCRIPT
	fi
done

GREEN='\033[0;32m'
NC='\033[0m'
# Note that any log messages go to stderr, so that we can save return value
# of ide command into a bash variable. E.g.
# version=$(ide some-command-to-get-version)
# This is not needed if you don't intend to save it.
if [ -t 0 ] ; then
    # interactive shell
    echo -e "${GREEN}ide init finished (interactive shell)${NC}" >&2

    # No "set -e" here, you don't want to be logged out when sth returns not 0
    # in interactive shell.
    set +e
else
    # not interactive shell
    echo -e "${GREEN}ide init finished (not interactive shell)${NC}" >&2
    set -e
fi

if [ -n "$this_image_name" ] || [ -n "$this_image_tag" ]; then
  # variables set
  echo -e "${GREEN}using ${this_image_name}:${this_image_tag}${NC}" >&2
fi

sudo -E -H -u ide /bin/bash -lc "$@"
