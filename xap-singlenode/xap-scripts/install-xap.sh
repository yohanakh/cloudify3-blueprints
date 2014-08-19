#!/bin/bash

source ${CLOUDIFY_LOGGING}

YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)

cfy_info "getting java"
# Get Java
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y install java-1.7.0-openjdk || exit $?   
else
   sudo apt-get -qq install openjdk-7-jdk || exit $?   
fi

cfy_info "getting unzip"
# Get Unzip
if [[ ! -z $YUM_CMD ]]; then
   sudo yum -y install unzip || exit $?   
else
   sudo apt-get -qq install unzip || exit $?   
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

  # Update license
  ed $GSDIR/gslicense.xml <<EOF
g/\(<licensekey>\).*\(<\/licensekey>\)/s//\1${license_key}\2/
w
q
EOF

  # unzip scripts
  pushd $GSDIR/bin
  unzip advanced_scripts.zip	
  popd

fi


