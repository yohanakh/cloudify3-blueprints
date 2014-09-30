#!/bin/bash

source ${CLOUDIFY_LOGGING}

if [ -f /tmp/butterfly.pid ]; then
	PID=`cat /tmp/butterfly.pid`
	cfy_info "killing butterfly pid=$PID"
	kill $PID
else
	cfy_error "no pid file found for butterfly"
	exit 1
fi

