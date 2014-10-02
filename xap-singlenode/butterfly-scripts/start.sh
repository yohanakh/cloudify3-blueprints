#!/bin/sh
source ${CLOUDIFY_LOGGING}

function error_exit {
   cfy_error "$2 : error code: $1"
   exit ${1}
}
IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
GSDIR=`cat /tmp/gsdir`
LOOKUPLOCATORS=$IP_ADDR
if [ -f "/tmp/locators" ]; then
	LOOKUPLOCATORS=""
	for line in $(cat /tmp/locators); do
		LOOKUPLOCATORS="${LOOKUPLOCATORS}${line},"
	done
  	LOOKUPLOCATORS=${LOOKUPLOCATORS%%,}  #trim trailing comma
fi

export LOOKUPLOCATORS
export NIC_ADDR=${IP_ADDR}
export GS_GROOVY_HOME=$GSDIR/tools/groovy/
export {LRMI_COMM_MIN_PORT:=7122}
export {LRMI_COMM_MAX_PORT:=7222}
export EXT_JAVA_OPTIONS="-Dcom.gs.multicast.enabled=false -Dcom.gs.transport_protocol.lrmi.bind-port=$LRMI_COMM_MIN_PORT-$LRMI_COMM_MAX_PORT -Dcom.gigaspaces.start.httpPort=7104 -Dcom.gigaspaces.system.registryPort=7102"


export GS_HOME=$GSDIR



UUID=asdfsd

source ~/.bashrc
source /tmp/virtenv_is/bin/activate

UUID=`uuidgen`

cfy_info "launching butterfly server"
python /tmp/demodl/butterfly/butterfly.server.py --host="0.0.0.0" --port="$port" --unsecure --prompt_login=false --load_script="/tmp/demodl/XAP-Interactive-Tutorial-master/start_tutorial.sh" --wd="/tmp/demodl/XAP-Interactive-Tutorial-master" $UUID 2>&1 >/tmp/demodl.nohup.out &
sleep 1
cfy_info "launched butterfly server"
deactivate
cfy_info "deactivated"

echo $! > /tmp/butterfly.pid

