#!/bin/bash

source ${CLOUDIFY_LOGGING}

if [ -f /tmp/webui.pid ]; then
	PID=`cat /tmp/webui.pid`
	cfy_info "killing webui pid=$PID"
	kill $PID
else
	cfy_error "no pid file found for webui"
	exit 1
fi

