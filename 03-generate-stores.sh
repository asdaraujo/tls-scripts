#!/bin/bash

BASE_DIR=$( readlink -f $( dirname $0 ) )

if [[ $# != 1 || "$1" != *"."* ]]; then
  echo "Syntax: $0 <host_fqdn>"
  exit 1
fi

HOST=$1
source $BASE_DIR/00-common.sh

if [ ! -r "$server_cert_file" -o ! -r "$int_ca_cert_file" -o ! -r "$root_ca_cert_file" ]; then
  echo "ERROR: Certificate file $server_cert_file not found"
  echo "       Before proceeding execute the following:"
  echo "        - Send the $csr_file to your CA to be signed"
  echo "        - Save the certificate provided by the CA as $server_cert_file"
  echo "        - Save the Intermediate CA certificate as $int_ca_cert_file"
  echo "        - Save the Root CA certificate as $root_ca_cert_file"
  exit 1
fi

echo -en "Password for $key_file: "
read -s kspwd
echo ""

echo -en "Truststore password: "
read -s tspwd
echo -en "\nConfirm keystore password: "
read -s tspwd2
echo ""

if [ "$tspwd" != "$tspwd2" ]; then
  echo "ERROR: Passwords don't match" 
  exit 1
fi

if [ "$tspwd" == "$kspwd" ]; then
  echo "ERROR: Truststore and Keystore passwords should be different" 
  exit 1
fi

# Combine server and intermediate certs
cat $server_cert_file $int_ca_cert_file > $cert_file

# Combine certs with the private key
tempstorepwd=$RANDOM$RANDOM
openssl pkcs12 \
  -export \
  -in $cert_file \
  -inkey <(openssl rsa \
             -in $key_file \
             -passin pass:"$kspwd") \
  -out $pkcs12_keystore \
  -passout pass:$tempstorepwd \
  -name $HOST

# Convert PKCS12 into a JKS keystore
rm -f $jks_keystore
keytool \
  -importkeystore \
  -alias $HOST \
  -srcstoretype PKCS12 \
  -srckeystore $pkcs12_keystore \
  -destkeystore $jks_keystore \
  -srcstorepass $tempstorepwd \
  -deststorepass "$kspwd" \
  -destkeypass "$kspwd"
rm -f $pkcs12_keystore

# Create truststore in PEM format
cp -f $root_ca_cert_file $pem_truststore

# Create truststore in JKS format
rm -f $jks_truststore
keytool \
  -importcert \
  -file $root_ca_cert_file \
  -alias root-ca \
  -keystore $jks_truststore \
  -storepass "$tspwd" \
  -noprompt

echo -e "\nPEM certificate chain: $cert_file"
echo -e "PEM truststore:        $pem_truststore"
echo -e "JKS keystore:          $jks_keystore"
echo -e "JKS truststore:        $jks_truststore"

echo -e "\nNOTE: The keystore passphrase is the same passphrase used originally for the key\n"

