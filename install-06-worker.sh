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
# Install software on workers
source ./settings.sh
if ! isWorker ; then
  echo $(hostname | tr [:upper:] [:lower:]) is not worker node, skipping worker installation.
  exit 0
fi
# yum install -y socat conntrack ipset
mkdir -p \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
cd binaries
chmod +x kubectl kube-proxy kubelet
cp kubectl kube-proxy kubelet /usr/local/bin/

cd ..
pushd generated-files > /dev/null


# Set up Kubernetes control plane
cp ca.pem /var/lib/kubernetes/
cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem encryption-config.yaml /var/lib/kubernetes/
cp kubelet-$(hostname | tr [:upper:] [:lower:]).kubeconfig /var/lib/kubelet/kubeconfig
cp worker-$(hostname | tr [:upper:] [:lower:])-key.pem /var/lib/kubelet/$(hostname | tr [:upper:] [:lower:])-key.pem
cp worker-$(hostname | tr [:upper:] [:lower:]).pem /var/lib/kubelet/$(hostname | tr [:upper:] [:lower:]).pem
cp kube-proxy-$(hostname | tr [:upper:] [:lower:]).kubeconfig /var/lib/kube-proxy/kubeconfig
cp worker-$(hostname | tr [:upper:] [:lower:])-kubelet.service /etc/systemd/system/kubelet.service
cp worker-$(hostname | tr [:upper:] [:lower:])-kube-proxy.service /etc/systemd/system/kube-proxy.service

systemctl daemon-reload
systemctl enable kubelet kube-proxy
systemctl start kubelet kube-proxy

popd > /dev/null
