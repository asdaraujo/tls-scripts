#!/bin/bash

BASE_DIR=$( readlink -f $( dirname $0 ) )

if [[ $# != 1 || "$1" != *"."* ]]; then
  echo "Syntax: $0 <host_fqdn>"
  exit 1
fi

HOST=$1
source $BASE_DIR/00-common.sh

# Creates a new private key
openssl genrsa -des3 -out $key_file 2048

echo -e "\nKey file: $key_file\n"
