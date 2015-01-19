#!/bin/bash

source ${CLOUDIFY_LOGGING}

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

cfy_info "getting java"
# Get Java
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y -q install java-1.7.0-openjdk || exit $?   
else
   sudo apt-get -f install libdevmapper-event1.02.1
   sudo apt-get -qq --no-upgrade install openjdk-7-jdk || exit $?   
fi

cfy_info "getting unzip"
# Get Unzip
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y -q install unzip || exit $?   
else
   sudo apt-get -qq -f --no-upgrade install unzip || exit $?
fi

# Get XAP

DIR=/tmp


# check only needed for local cloud 
if [ ! -d $DIR/xap ]; then
  mkdir $DIR/xap
  pushd $DIR/xap
  cfy_info "getting xap from ${download_url}"
  wget -N ${download_url}

  unzip *.zip
  popd

  GSDIR=`ls -d $DIR/xap/gigaspaces*premium*ga`
  echo $GSDIR > /tmp/gsdir

  cfy_info "GSDIR=$GSDIR" 
  cfy_info "license_key=${license_key}"

  # Update license
  AS='s!\(.*\)\(<licensekey>\)\(.*\)\(<\/licensekey>\)\(.*\)!\1\2'$license_key'\4\5!'
  cfy_info "AS=$AS"

  sed -i -e "$AS" $GSDIR/gslicense.xml

  # unzip scripts
  pushd $GSDIR/bin
  unzip advanced_scripts.zip	
  popd

  # add dynamic nat mapper (needed for gateway)
  wget -O $GSDIR/lib/required/nat-mapper.jar "${CLOUDIFY_FILE_SERVER_BLUEPRINT_ROOT}/xap-scripts/nat-mapper.jar"


fi

