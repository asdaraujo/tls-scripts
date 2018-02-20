#!/bin/bash

# This file must be loaded after HOST is set
set -o nounset
set -o errexit

export JAVA_HOME=/usr/java/jdk1.8.0_144
export PATH=$JAVA_HOME/bin:$PATH

mkdir -p tmp keys reqs deploy/pem deploy/jks ca
chmod 700 tmp keys reqs deploy/pem deploy/jks ca

# PEM key file
key_file=keys/$HOST-key.pem
# PEM certificate for the HOST - contains server + intermediate certs
cert_file=deploy/pem/$HOST-cert.pem
# Signed certificate for the server received from CA
server_cert_file=reqs/$HOST-servercert.pem
# Root CA certificate
root_ca_cert_file=ca/root-ca-cert.pem
# Intermediate CA certificate
int_ca_cert_file=ca/int-ca-cert.pem
# CSR file for the request of the server certificate
csr_file=reqs/$HOST.csr
# Temporary PKCS12 store - only for conversion purposes
pkcs12_keystore=tmp/$HOST.p12
# JKS keystore
jks_keystore=deploy/jks/$HOST.jks
# JKS truststore
jks_truststore=deploy/jks/truststore.jks
# PEM truststore
pem_truststore=deploy/pem/truststore.pem
# Server certificate subject
subj="/C=US/ST=CA/L=San Francisco/O=Example/OU=Analytics/CN=$HOST"
# Deployment base directory
deployment_dir=/opt/cloudera/security
