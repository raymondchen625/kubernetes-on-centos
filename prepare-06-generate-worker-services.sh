#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
source ./settings.sh
pushd generated-files > /dev/null
# Generate kubelet and kube-proxy service unit file
for index in ${!WORKER_HOSTNAME_LIST[@]}; do
WORKER_HOSTNAME=${WORKER_HOSTNAME_LIST[$index]}
INTERNAL_IP=${WORKER_IP_LIST[$index]}
generateFromTemplate ../services/kubelet.service worker-${WORKER_HOSTNAME}-kubelet.service
generateFromTemplate ../services/kube-proxy.service worker-${WORKER_HOSTNAME}-kube-proxy.service
done

popd > /dev/null
