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
source ./settings.sh
if ! isController ; then
  echo $(hostname | tr [:upper:] [:lower:]) is not controller node, skipping configuring RBAC.
  exit 0
fi
pushd generated-files > /dev/null
generateFromTemplate ../templates/rbac.yaml rbac.yaml
kubectl apply -f rbac.yaml
popd > /dev/null
