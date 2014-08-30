#!/bin/bash

source ${CLOUDIFY_LOGGING}

LOOKUPLOCATORS=""
if [ -f "/tmp/locators" ]; then
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

XAPDIR=`cat /tmp/gsdir`  # left by install script

echo 1 | $XAPDIR/bin/gs.sh gsa shutdown
