#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
source ./settings.sh
pushd generated-files > /dev/null

# Generate api-server, kube-controller-manager and kube-scheduler service unit file

# Generate etcd service unit file
ETCD_SERVERS=""
declare -a clusterArray
for index in ${!ETCD_IP_LIST[@]}; do
  clusterArray[$index]="https://${ETCD_IP_LIST[$index]}:2379"
  echo $index ${clusterArray[$index]}
done
ETCD_SERVERS=`joinBy , "${clusterArray[@]}"`
echo ETCD_SERVERS=${ETCD_SERVERS}
for index in ${!CONTROLLER_HOSTNAME_LIST[@]}; do
CONTROLLER_NAME=${CONTROLLER_HOSTNAME_LIST[$index]}
INTERNAL_IP=${CONTROLLER_IP_LIST[$index]}

generateFromTemplate ../services/kube-apiserver.service kube-apiserver-${CONTROLLER_NAME}.service

generateFromTemplate ../services/kube-controller-manager.service kube-controller-manager-${CONTROLLER_NAME}.service

generateFromTemplate ../services/kube-scheduler.service kube-scheduler-${CONTROLLER_NAME}.service

done

popd > /dev/null
