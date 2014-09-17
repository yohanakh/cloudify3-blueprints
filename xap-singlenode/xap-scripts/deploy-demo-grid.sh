#!/bin/bash

source ${CLOUDIFY_LOGGING}

XAPDIR=`cat /tmp/gsdir`  # left by install script

IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

cfy_info "deploying space, locators=$LOOKUPLOCATORS"
$XAPDIR/bin/gs.sh deploy-space myDataGrid
