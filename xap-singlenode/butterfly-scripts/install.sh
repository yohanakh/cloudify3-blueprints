#!/bin/bash
#
# Installs the butterfly console.  Assumes it is installed on a node
# running a XAP lookup service

source ${CLOUDIFY_LOGGING}

function error_exit {
   cfy_error "$2 : error code: $1"
   exit ${1}
}

source ${CLOUDIFY_FILE_SERVER}

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

if [ ! -d /tmp/demodl ]; then
  DLDIR=/tmp/demodl
  mkdir $DLDIR
  pushd $DLDIR
  wget "${demo_url}"
  unzip *.zip
  chmod +x *.sh
fi

if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y update
else
   cfy_info "running apt-get update"
   sudo apt-get clean all
   sudo dpkg --configure -a
   sudo apt-get -qq update
   cfy_info "installing python-setuptools with apt-get"
   sudo apt-get install python-setuptools || error_exit $? "Failed to install requirements ( python-setuptools)"
fi

sudo easy_install virtualenv || error_exit $? "Failed on: easy_install virtualenv"
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
cd /tmp/demodl/
git clone "${butterfly_repo}" || error_exit $? "Failed to clone butterfly repository"
cd butterfly/ || error_exit $? "Failed to cd butterfly"
   cfy_info "installing butterfly"
python setup.py install || error_exit $? "Failed on: python setup.py install"
   cfy_info "done installing butterfly"
deactivate


