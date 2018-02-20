#!/bin/bash

BASE_DIR=$( readlink -f $( dirname $0 ) )

if [[ $# != 1 || "$1" != *"."* ]]; then
  echo "Syntax: $0 <host_fqdn>"
  exit 1
fi

HOST=$1
source $BASE_DIR/00-common.sh

pem_dir=$deployment_dir/pem
jks_dir=$deployment_dir/jks
ssh -q $HOST "\
mkdir -p $pem_dir \
         $jks_dir;\
chmod 755 $deployment_dir \
          $pem_dir \
          $jks_dir"
scp -q $key_file $cert_file $pem_truststore $HOST:$pem_dir
scp -q $jks_keystore $jks_truststore $HOST:$jks_dir
ssh -q $HOST "\
echo "\""Hostname: \$(hostname -f)"\"";\
rm -f $pem_dir/cert.pem $pem_dir/key.pem $jks_dir/keystore.jks;\
ln -s $pem_dir/$(basename $cert_file) $pem_dir/cert.pem;\
ln -s $pem_dir/$(basename $key_file) $pem_dir/key.pem;\
ln -s $jks_dir/$(basename $jks_keystore) $jks_dir/keystore.jks;\
chmod 444 $pem_dir/* $jks_dir/*;\
ls -l $pem_dir/{cert.pem,key,$(basename $cert_file),$(basename $key_file),$(basename $pem_truststore)} \
      $jks_dir/{keystore.jks,$(basename $jks_keystore),$(basename $jks_truststore)};\
"

