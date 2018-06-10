#!/bin/bash
# Install software on controllers
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
  echo $(hostname | tr [:upper:] [:lower:]) is not controller node, skipping controller service installation.
  exit 0
fi

cd binaries

chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl etcdctl
cp kube-apiserver kube-controller-manager kube-scheduler kubectl etcdctl /usr/local/bin

pushd ../generated-files > /dev/null

# Set up Kubernetes control plane
mkdir -p /var/lib/kubernetes/
cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem encryption-config.yaml /var/lib/kubernetes/
cp kube-apiserver-$(hostname | tr [:upper:] [:lower:]).service /etc/systemd/system/kube-apiserver.service
cp kube-scheduler-$(hostname | tr [:upper:] [:lower:]).service /etc/systemd/system/kube-scheduler.service
cp kube-controller-manager-$(hostname | tr [:upper:] [:lower:]).service /etc/systemd/system/kube-controller-manager.service
systemctl daemon-reload
systemctl enable kube-apiserver kube-controller-manager kube-scheduler
systemctl start kube-apiserver kube-controller-manager kube-scheduler
sleep 5
kubectl get componentstatuses
popd > /dev/null
