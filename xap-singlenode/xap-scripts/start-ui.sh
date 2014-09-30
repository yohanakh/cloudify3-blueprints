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
export LOOKUPLOCATORS
export NIC_ADDR=${IP_ADDR}
export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.bind-port=7122-7222 -Dcom.gigaspaces.start.httpPort=7104 -Dcom.gigaspaces.system.registryPort=7102"

cfy_info "locators=$LOOKUPLOCATORS"

$XAPDIR/bin/gs-webui.sh &

echo $! > /tmp/webui.pid

cfy_info "webui started"
