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
  echo $(hostname | tr [:upper:] [:lower:]) is not controller node, skipping generating admin kubeconfig.
  exit 0
fi
pushd generated-files > /dev/null

kubectl config set-cluster ${CLUSTER_NAME} \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${API_SERVER_IP}:6443
kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem
kubectl config set-context ${CLUSTER_NAME} \
    --cluster=${CLUSTER_NAME} \
    --user=admin
kubectl config use-context ${CLUSTER_NAME}

# verify
kubectl get componentstatuses

popd > /dev/null
