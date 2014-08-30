#!/bin/bash
#
# Installs the butterfly console.  Assumes it is installed on a node
# running a XAP lookup service

source ${CLOUDIFY_LOGGING}

function error_exit {
   cfy_error "$2 : error code: $1"
   exit ${1}
}

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

DLDIR=/tmp/demodl
mkdir $DLDIR

pushd $DLDIR

source ${CLOUDIFY_FILE_SERVER}

#HACK: should wget from demo_url
wget "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/butterfly-scripts/DemoScript.zip"
#wget $demo_url

unzip *.zip

chmod +x *.sh

virtualenv /tmp/virtenv_is --no-site-packages || error_exit $? "Failed on: virtualenv virtenv"
source /tmp/virtenv_is/bin/activate
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y update
   sudo yum -y install git python-pip gcc python-devel openssl-devel || error_exit $? "Failed to install requirements (git python-pip gcc python-devel)"
else
   cfy_info "running apt-get update"
   sudo apt-get clean all
   sudo dpkg --configure -a
   sudo apt-get -qq update
   cfy_info "installing misc with apt-get"
   sudo apt-get -qq install git python-pip gcc python-dev libssl-dev || error_exit $? "Failed to install requirements (git python-pip gcc python-devel)"
   cfy_info "installing openssl with pip"
fi
pip install pyOpenSSL==0.12 || error_exit $? "Failed to install pyOpenSSL v0.12"
   cfy_info "cloning butterfly repo"
git clone https://github.com/yohanakh/butterfly.git || error_exit $? "Failed to clone butterfly repository"
cd butterfly/ || error_exit $? "Failed to cd butterfly"
   cfy_info "installing butterfly"
python setup.py install || error_exit $? "Failed on: python setup.py install"
   cfy_info "done installing butterfly"
deactivate


