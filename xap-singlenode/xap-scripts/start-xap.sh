#!/bin/bash

source ${CLOUDIFY_LOGGING}
source ${CLOUDIFY_FILE_SERVER}

wget -O /tmp/util.sh "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/util.sh"
wget -O /tmp/jq "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/jq"
chmod +x /tmp/jq
source /tmp/util.sh

sudo ulimit -n 32000
sudo ulimit -u 32000

XAPDIR=`cat /tmp/gsdir`  # left by install script

cfy_info gsm=$gsm_cnt gsc=$gsc_cnt lus=$lus_cnt

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

export LOOKUPLOCATORS
export NIC_ADDR=$LOOKUPLOCATORS
export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false"

PS=`ps -eaf|grep -v grep|grep GSA`

if [ "$PS" = "" ]; then  #no gsa running already

	cfy_info "running gs-agent.sh from $CLOUDIFY_NODE_ID"

	nohup $XAPDIR/bin/gs-agent.sh gsa.global.lus=$global_lus_cnt gsa.lus=$lus_cnt gsa.global.gsm=$global_gsm_cnt gsa.gsm $gsm_cnt gsa.gsc=$gsc_cnt 2>&1 >/tmp/xap.nohup.out &

	sleep 10

else #running local cloud

	if [ $gsm_cnt -gt 0 ]; then
		echo $gsm_cnt|$XAPDIR/bin/gs.sh gsa start-gsm
	fi
	if [ $lus_cnt -gt 0 ]; then
		echo $lus_cnt|$XAPDIR/bin/gs.sh gsa start-lus
	fi
	if [ $gsc_cnt -gt 0 ]; then
		echo $gsc_cnt|$XAPDIR/bin/gs.sh gsa start-gsc
	fi

fi
