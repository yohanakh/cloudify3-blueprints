#!/bin/bash
set -x
space_name=$(ctx node properties space_name)
gsc_cnt=$(ctx node properties gsc_cnt)
zones=$(ctx node properties zones)
discport=$(ctx node properties discport)
commport=$(ctx node properties commport)
gwname=$(ctx node properties gwname)
sources=$(ctx node properties sources)
targets=$(ctx node properties targets)
lookups=$(ctx node properties lookups)
GSC_JAVA_OPTIONS=$(ctx node properties GSC_JAVA_OPTIONS)
restpu_zones=$(ctx node properties restpu_zones)
space_zones=$(ctx node properties space_zones)

ctx logger info "GOT LOOKUPS:[${lookups}], SOURCES:[$sources], TARGETS:[$targets], GSC_CNT:[$gsc_cnt], discport:[$discport]"

ctx download-resource xap-scripts/deploy-space-with-gateway.groovy '@{"target_path": "/tmp/deploy-space-with-gateway.groovy"}'
ctx download-resource xap-scripts/startgsc.groovy '@{"target_path": "/tmp/startgsc.groovy"}'
ctx download-resource xap-scripts/install_gateway.groovy '@{"target_path": "/tmp/install_gateway.groovy"}'
ctx download-resource xap-scripts/gateway-pu.xml '@{"target_path": "/tmp/gateway-pu.xml"}'
ctx download-resource xap-scripts/space-pu.xml '@{"target_path": "/tmp/space-pu.xml"}'

#sudo ulimit -n 32000
#sudo ulimit -u 32000

XAPDIR=`cat /tmp/gsdir`  # left by install script

# Update IP
interfacename=$(ctx node properties interfacename)
IP_ADDR=$(ip addr | grep inet | grep ${interfacename} | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
export NIC_ADDR=$IP_ADDR
ctx logger info "About to post IP address ${IP_ADDR}"

ctx instance runtime_properties "ip_address" $IP_ADDR

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
export LOOKUPLOCATORS
ctx logger info "LOOKUPLOCATORS: ${LOOKUPLOCATORS}"
# Write empty NAT mapping file (required by mapper)
echo > /tmp/network_mapping.config

PS=`ps -eaf|grep -v grep|grep GSA`

export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.sun.jini.reggie.initialUnicastDiscoveryPort=${discport} -Dcom.gs.transport_protocol.lrmi.network-mapping-file=/tmp/network_mapping.config -Dcom.gs.transport_protocol.lrmi.network-mapper=org.openspaces.repl.natmapper.ReplNatMapper"
export GSC_JAVA_OPTIONS="$GSC_JAVA_OPTIONS -Dcom.gs.transport_protocol.lrmi.bind-port=${commport}"
if [ -n "${zones}" ]; then
	ZONES=$zones
else
	ZONES="${space_name}-gw"
fi

GROOVY=$XAPDIR/tools/groovy/bin/groovy

if [ "$PS" = "" ]; then  #no gsa running already
	ctx logger info "NO GSA IS RUNNING!"

	export GSC_JAVA_OPTIONS="$GSC_JAVA_OPTIONS -Dcom.gs.zones=${ZONES}"

	ctx logger info "running gs-agent.sh from $CLOUDIFY_NODE_ID"

	nohup $XAPDIR/bin/gs-agent.sh gsa.global.lus=0 gsa.lus=0 gsa.global.gsm=0 gsa.gsm 0 gsa.gsc=1 >/tmp/xap.nohup.out 2>&1 &
	sleep 10

else 
	ctx logger info "THERE IS A RUNNUNG GSA!"

	ctx logger info "GSA already running"

	EXT_JAVA_OPTIONS="${EXT_JAVA_OPTIONS} -Dcom.gs.zones=${ZONES}"

	ctx logger info "calling:  $GROOVY -Dinterfacename=\"${interfacename}\" -Dgsc_cnt=\"${gsc_cnt}\" /tmp/startgsc.groovy \"$GSC_JAVA_OPTIONS $EXT_JAVA_OPTIONS\""

	$GROOVY -Dinterfacename="${interfacename}" -Dgsc_cnt="${gsc_cnt}" /tmp/startgsc.groovy "$GSC_JAVA_OPTIONS $EXT_JAVA_OPTIONS" > "/tmp/yohanakh.log"

	ctx logger info "called startgsc"

fi

# Create and deploy pu
# first add this gateway to lookups

lookups=${lookups%"]"}
lookups="${lookups},[\"gwname\":\"$gwname\",\"address\":\"$IP_ADDR\",\"discoport\":$discport,\"commport\":$commport]]"

ctx logger info "calling $GROOVY -DXAPDIR=\"$XAPDIR\" -Dspacename=\"$space_name\" -Dgwname=\"$gwname\" -Dlocallocators=\"$LOOKUPLOCATORS\" -Dxapdir=\"$XAPDIR\" -Dtargets=\"$targets\" -Dzones=\"${space_zones}\" /tmp/deploy-space-with-gateway.groovy"
$GROOVY -Djava.rmi.server.hostname="${NIC_ADDR}" -DXAPDIR="$XAPDIR" -Dspacename="$space_name" -Dgwname="$gwname" -Dlocallocators="$LOOKUPLOCATORS" -Dxapdir="$XAPDIR" -Dtargets="$targets" -Dzones="${space_zones}" /tmp/deploy-space-with-gateway.groovy

ctx logger info "$GROOVY -Djava.rmi.server.hostname=\"${NIC_ADDR}\" -Dpuname=\"${space_name}-gw\" -Dspacename=\"${space_name}\" -Dzones=\"$ZONES\" -Dlocallocators=\"$LOOKUPLOCATORS\" -Dlocalgwname=\"${gwname}\" -Dtargets=\"${targets}\" -Dsources=\"${sources}\" -Dlookups=\"${lookups}\" -Dnatmappings=\"${nat_mappings}\"  /tmp/install_gateway.groovy"
$GROOVY -Djava.rmi.server.hostname="${NIC_ADDR}" -Dpuname="${space_name}-gw" -Dspacename="${space_name}" -Dzones="$ZONES" -Dlocallocators="$LOOKUPLOCATORS" -Dlocalgwname="${gwname}" -Dtargets="${targets}" -Dsources="${sources}" -Dlookups="${lookups}" -Dnatmappings="${nat_mappings}"  /tmp/install_gateway.groovy

#export EXT_JAVA_OPTIONS=
if [ -z "${restpu_zones}" ]; then
ctx logger info "$XAPDIR/bin/gs.sh deploy-rest -spacename $space_name -port 8888"
$XAPDIR/bin/gs.sh deploy-rest -spacename ${space_name} -port 8888
else
ctx logger info "$XAPDIR/bin/gs.sh deploy-rest -spacename $space_name -port 8888 -zones ${restpu_zones}"
$XAPDIR/bin/gs.sh deploy-rest -spacename ${space_name} -port 8888 -zones ${restpu_zones}
fi