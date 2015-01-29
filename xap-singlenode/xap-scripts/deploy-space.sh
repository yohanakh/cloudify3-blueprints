#!/bin/bash

source ${CLOUDIFY_LOGGING}
source ${CLOUDIFY_FILE_SERVER}


# get the canned space.  Only thing special is that it has the
# site name and a reference to an enpty targets block

wget -O /tmp/space-pu.jar "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/space-pu.jar"

XAPDIR=`cat /tmp/gsdir`  # left by install script
interfacename=$(ctx node properties interfacename)
IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export LOOKUPLOCATORS=$IP_ADDR
export ZONES=$zones
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
	export LOOKUPLOCATORS
fi

cfy_info "deploying space, locators=$LOOKUPLOCATORS clusterinfo=$cluster_info"
$XAPDIR/bin/gs.sh deploy -properties "embed://spaceName=${space_name};siteName=${site_name}" -cluster $cluster_info /tmp/space-pu.jar >/tmp/deploy.out 2>&1
