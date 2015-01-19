#!/bin/bash

PU_LOCATION=$1
PU_NAME=$2
SCHEMA=$3
PARTITION=$4
BACKUPS=$5
MAX_PER_VM=$6
MAX_PER_MACHINE=$7


XAPDIR=`cat /tmp/gsdir`  # left by install script

IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
export NIC_ADDR=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

$XAPDIR/bin/gs.sh deploy -cluster schema=${SCHEMA} total_members=${PARTITION},${BACKUPS} -max-instances-per-vm ${MAX_PER_VM} -max-instances-per-machine ${MAX_PER_MACHINE} -override-name ${PU_NAME} ${PU_LOCATION}
