#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
source ./settings.sh
pushd generated-files > /dev/null

# Generate kubelet kubeconfig for workers
for index in ${!WORKER_IP_LIST[@]}; do
  kubectl config set-cluster ${CLUSTER_NAME} \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${API_SERVER_IP}:6443 \
    --kubeconfig=kubelet-${WORKER_HOSTNAME_LIST[index]}.kubeconfig

  kubectl config set-credentials system:node:${WORKER_HOSTNAME_LIST[index]} \
    --client-certificate=worker-${WORKER_HOSTNAME_LIST[index]}.pem \
    --client-key=worker-${WORKER_HOSTNAME_LIST[index]}-key.pem \
    --embed-certs=true \
    --kubeconfig=kubelet-${WORKER_HOSTNAME_LIST[index]}.kubeconfig

  kubectl config set-context default \
    --cluster=${CLUSTER_NAME} \
    --user=system:node:${WORKER_HOSTNAME_LIST[index]} \
    --kubeconfig=kubelet-${WORKER_HOSTNAME_LIST[index]}.kubeconfig

  kubectl config use-context default --kubeconfig=kubelet-${WORKER_HOSTNAME_LIST[index]}.kubeconfig
done

# Generate kube-proxy kubeconfig for workers
for index in ${!WORKER_IP_LIST[@]}; do
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${API_SERVER_IP}:6443 \
  --kubeconfig=kube-proxy-${WORKER_HOSTNAME_LIST[index]}.kubeconfig
kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy-${WORKER_HOSTNAME_LIST[index]}.kubeconfig
kubectl config set-context default \
  --cluster=${CLUSTER_NAME} \
  --user=kube-proxy \
  --kubeconfig=kube-proxy-${WORKER_HOSTNAME_LIST[index]}.kubeconfig
kubectl config use-context default --kubeconfig=kube-proxy-${WORKER_HOSTNAME_LIST[index]}.kubeconfig
done

# Generate one admin kubeconfig for all workers
kubectl config set-cluster ${CLUSTER_NAME} \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${API_SERVER_IP}:6443 \
    --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

kubectl config set-context default \
    --cluster=${CLUSTER_NAME} \
    --user=admin \
    --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig

# Generate random encryption key
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
generateFromTemplate ../templates/encryption-config.yaml encryption-config.yaml

popd > /dev/null
