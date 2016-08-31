#!/bin/bash

###########################################################################
# This file is an init script to properly start ide docker container.
###########################################################################

set -e

# run any additional scripts to setup custom configuration files or secrets
# or source any files like /etc/docker_metadata.txt or wait for linux daemons
for SCRIPT in /etc/ide.d/* ; do
	if [ -f $SCRIPT -a -x $SCRIPT ] ; then
		$SCRIPT
	fi
done

GREEN='\033[0;32m'
NC='\033[0m'
if [ -t 0 ] ; then
    # interactive shell
    echo -e "${GREEN}ide init finished (interactive shell)${NC}"

    # No "set -e" here, you don't want to be logged out when sth returns not 0
    # in interactive shell.
    set +e
else
    # not interactive shell
    echo -e "${GREEN}ide init finished (not interactive shell)${NC}"
    set -e
fi

if [ -n "$this_image_name" ] || [ -n "$this_image_tag" ]; then
  # variables set
  echo -e "${GREEN}using ${this_image_name}:${this_image_tag}${NC}"
fi

sudo -E -H -u ide /bin/bash -lc "$@"