#!/bin/bash

source ${CLOUDIFY_LOGGING}

IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
export NIC_ADDR=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

XAPDIR=`cat /tmp/gsdir`  # left by install script

if [ -f "/tmp/input" ]; then
    touch /tmp/input
    echo "1" > input
fi
echo 1 | $XAPDIR/bin/gs.sh gsa shutdown < input
