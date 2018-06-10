#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
source ./settings.sh
pushd generated-files > /dev/null
function join_by { local IFS="$1"; shift; echo "$*"; }
# Generate etcd service unit file
INITIAL_CLUSTER=""
declare -a clusterArray
for index in ${!ETCD_HOSTNAME_LIST[@]}; do
  clusterArray[$index]="${ETCD_HOSTNAME_LIST[$index]}=https://${ETCD_IP_LIST[$index]}:2380"
done
INITIAL_CLUSTER=`join_by , "${clusterArray[@]}"`
for index in ${!ETCD_HOSTNAME_LIST[@]}; do
ETCD_NAME=${ETCD_HOSTNAME_LIST[$index]}
INTERNAL_IP=${ETCD_IP_LIST[$index]}

generateFromTemplate ../services/etcd.service etcd-${ETCD_NAME}.service

done

popd > /dev/null
