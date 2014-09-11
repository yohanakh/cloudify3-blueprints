#!/bin/sh
#
# BASH Utilities
#

########################################################
# Set a runtime property
# $1=key1 $2=value1 $3=key2 $4 value2 ...

function set_runtime_properties {

  cfy_info "Getting latest state version of current node ${CLOUDIFY_NODE_ID} from cloudify manager at ${CLOUDIFY_MANAGER_IP}"

  NODE_STATE=`curl -s -X GET "http://${CLOUDIFY_MANAGER_IP}:80/node-instances/${CLOUDIFY_NODE_ID}"`
  cfy_info "Node state is ${NODE_STATE}"

  VERSION=`echo ${NODE_STATE} | /tmp/jq  '.version'`
  cfy_info "version is ${VERSION}"

  RUNTIME_PROPERTIES="{\"runtime_properties\":{"

  while (($#)); do
    RUNTIME_PROPERTIES="$RUNTIME_PROPERTIES \"$1\":\"$2\","
    shift
    shift
  done
  RUNTIME_PROPERTIES=${RUNTIME_PROPERTIES%%,}  #trim trailing comma

  RUNTIME_PROPERTIES="$RUNTIME_PROPERTIES},\"version\":${VERSION}}"

  URL="http://${CLOUDIFY_MANAGER_IP}:80/node-instances/${CLOUDIFY_NODE_ID}"

  cfy_info "Runtime properties: ${RUNTIME_PROPERTIES}"
  cfy_info "Url: ${URL}"

  curl -X PATCH -H "Content-Type: application/json" -d "${RUNTIME_PROPERTIES}" ${URL}

  cfy_info "Successfully posted data to manager"

}

#######################################################
# Get the current ip
#

function get_ip {
  IP_ADDR=$(ip addr | grep inet | grep eth0 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
  cfy_info "About to post IP address ${IP_ADDR} and port ${port}"
}
