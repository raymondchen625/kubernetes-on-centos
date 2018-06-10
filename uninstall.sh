#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
# Run this on all machines
source ./settings.sh
if [ -x /usr/local/bin/kubectl ]; then
  echo Deleting depoyed Kubernetes objects...
  kubectl -n kube-system delete svc,deployments,daemonsets,ingress,po,rc --all
  sleep 5
fi
systemctl stop kubelet kube-proxy flanneld docker etcd
systemctl disable kubelet kube-proxy flanneld docker etcd

systemctl stop kube-apiserver kube-controller-manager kube-scheduler
systemctl disable kube-apiserver kube-controller-manager kube-scheduler

yum -y erase docker-ce.x86_64 docker-ce-selinux.noarch; rm -rf /etc/docker /usr/lib/systemd/system/docker.service /var/lib/docker
yum -y erase flannel.x86_64; rm -rf /etc/sysconfig/flanneld /usr/lib/systemd/system/flanneld.service

rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /var/lib/kubelet
rm -rf /var/lib/kube-proxy
rm -rf /var/lib/kubernetes
rm -rf /var/run/kubernetes
# Remove binaries of containerd and cri-containerd
rm -f /usr/local/sbin/runc /usr/local/bin/crictl /usr/local/bin/containerd /usr/local/bin/containerd-stress /usr/local/bin/critest /usr/local/bin/containerd-release /usr/local/bin/containerd-shim /usr/local/bin/ctr /usr/local/bin/cri-containerd

pushd /usr/local/bin > /dev/null
rm -rf etcd* kube-apiserver kube-controller-manager kube-scheduler kubectl kube-proxy kubelet
popd > /dev/null

rm -rf /var/lib/etcd /etc/etcd

# delete all servic units
pushd /etc/systemd/system/ > /dev/null
rm -f etcd.service kube-apiserver.service kube-controller-manager.service kubelet.service kube-proxy.service kube-scheduler.service
popd > /dev/null

# Delete cron job
rm -f /etc/cron.daily/k8s-cleanup.sh

pushd binaries > /dev/null
rm -rf etcd-v3.2.11-linux-amd64
popd > /dev/null
rm -rf generated-files
rm -rf ~/.kube
yum-complete-transaction --cleanup-only
systemctl daemon-reload
# clean up hosts file
for index in ${!WORKER_IP_LIST[@]}; do
  WORKER_HOSTNAME=${WORKER_HOSTNAME_LIST[index]}
  WORKER_IP=${WORKER_IP_LIST[index]}
  deleteFromHosts ${WORKER_IP} ${WORKER_HOSTNAME}
done
for index in ${!CONTROLLER_IP_LIST[@]}; do
  CONTROLLER_HOSTNAME=${CONTROLLER_HOSTNAME_LIST[index]}
  CONTROLLER_IP=${CONTROLLER_IP_LIST[index]}
  deleteFromHosts ${CONTROLLER_IP} ${CONTROLLER_HOSTNAME}
done
for index in ${!ETCD_IP_LIST[@]}; do
  ETCD_HOSTNAME=${ETCD_HOSTNAME_LIST[index]}
  ETCD_IP=${ETCD_IP_LIST[index]}
  deleteFromHosts ${ETCD_IP} ${ETCD_HOSTNAME}
done
