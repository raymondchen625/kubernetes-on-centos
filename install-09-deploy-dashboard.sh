#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
if [ ! -d generated-files ]; then
  echo "'generated-files' folder doesn't exist. Please copy it from the stating environment or run ./generate-settings.sh to generate."
  exit 1
fi
# Update /etc/hosts file
source ./settings.sh
if ! isController ; then
  echo $(hostname | tr [:upper:] [:lower:]) is not controller node, skipping deploying kube-dns and dashboard.
  exit 0
fi
pushd generated-files > /dev/null
generateFromTemplate ../templates/kube-dns.yaml kube-dns.yaml
generateFromTemplate ../templates/kubernetes-dashboard.yaml kubernetes-dashboard.yaml
kubectl apply -f kube-dns.yaml
kubectl apply -f kubernetes-dashboard.yaml
popd > /dev/null
# If access to api server is restricted to localhost, use the command below to create a tunnel on port 8089
# ssh -g -l admin -L 8089:localhost:8080 localhost
