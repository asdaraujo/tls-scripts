#!/bin/bash

BASE_DIR=$( readlink -f $( dirname $0 ) )

if [[ $# != 1 || "$1" != *"."* ]]; then
  echo "Syntax: $0 <host_fqdn>"
  exit 1
fi

HOST=$1
source $BASE_DIR/00-common.sh

# Creates a new CSR from existing private key
openssl req -new -key $key_file -subj "$subj" -out $csr_file

echo -e "\nCSR file: $csr_file\n"

echo "CSR contents:"
cat $csr_file

