#!/bin/bash

# Prepare the tools for generating certs and kubeconfig files
# curl -LO https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
# curl -LO https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
pushd binaries > /dev/null
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
cp cfssl_linux-amd64 /usr/local/bin/cfssl
cp cfssljson_linux-amd64 /usr/local/bin/cfssljson

cfssl version

# Install kubectl
chmod +x kubectl
cp kubectl /usr/local/bin/
kubectl version --client
popd > /dev/null
