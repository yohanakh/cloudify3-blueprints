#!/bin/bash

source ${CLOUDIFY_LOGGING}
source ${CLOUDIFY_FILE_SERVER}

wget -O /tmp/nat-mapper.jar "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/nat-mapper.jar"
wget -O /tmp/startgsc.groovy "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/startgsc.groovy"
wget -O /tmp/install_gateway.groovy "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/install_gateway.groovy"
wget -O /tmp/gateway-pu.xml "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/gateway-pu.xml"
wget -O /tmp/util.sh "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/util.sh"
wget -O /tmp/jq "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/jq"

chmod +x /tmp/jq
source /tmp/util.sh

sudo ulimit -n 32000
sudo ulimit -u 32000

XAPDIR=`cat /tmp/gsdir`  # left by install script

# Update IP
IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')

cfy_info "About to post IP address ${IP_ADDR}"

set_runtime_properties "ip_address" $IP_ADDR

export LOOKUPGROUPS=
export GSA_JAVA_OPTIONS
export LUS_JAVA_OPTIONS
export GSM_JAVA_OPTIONS
export GSC_JAVA_OPTIONS

LOOKUPLOCATORS=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
fi

# Write empty NAT mapping file (required by mapper)
echo > /tmp/network_mapping.config

PS=`ps -eaf|grep -v grep|grep GSA`

export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.bind-port=${comm_port} -Dcom.sun.jini.reggie.initialUnicastDiscoveryPort=${discovery_port} -Dcom.gs.transport_protocol.lrmi.network-mapping-file=/tmp/network_mapping.config -Dcom.gs.transport_protocol.lrmi.network-mapper=org.openspaces.repl.natmapper.ReplNatMapper"

if [ -n "${zones}" ]; then
	ZONES=$zones
else
	ZONES="${local_site}-gw"
fi

if [ "$PS" = "" ]; then  #no gsa running already
	export LOOKUPLOCATORS
	export NIC_ADDR=$LOOKUPLOCATORS

	GSC_JAVA_OPTIONS="$GSC_JAVA_OPTIONS -Dcom.gs.zones=${ZONES}"

	cfy_info "running gs-agent.sh from $CLOUDIFY_NODE_ID"

	nohup $XAPDIR/bin/gs-agent.sh gsa.global.lus=0 gsa.lus=0 gsa.global.gsm=0 gsa.gsm 0 gsa.gsc=1 2>&1 >/tmp/xap.nohup.out &

	sleep 10

else 

	GROOVY=$XAPDIR/tools/groovy/bin/groovy

	cfy_info "GSA already running"

	EXT_JAVA_OPTIONS="${EXT_JAVA_OPTIONS} -Dcom.gs.zones=${ZONES}"

	cfy_info "calling:  $GROOVY /tmp/startgsc.groovy \"$JAVA_OPTIONS $EXT_JAVA_OPTIONS\""

	$GROOVY /tmp/startgsc.groovy "$JAVA_OPTIONS $EXT_JAVA_OPTIONS"

	cfy_info "called startgsc"

fi

# Create and deploy pu
# first add this gateway to lookups

lookups=${lookups%"]"}
lookups="${lookups},[gwname:$local_site,address:$IP_ADDR,discoport:$discovery_port,commport:$comm_port]]"

$GROOVY /tmp/install_gateway.groovy "${local_site}-gw" "${space_name}" "$ZONES" "$LOOKUPLOCATORS" "${local_site}" "${targets}" "${sources}" "${lookups}" "${nat_mappings}"

