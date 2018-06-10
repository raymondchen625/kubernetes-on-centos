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
if ! isEtcd ; then
  echo $(hostname | tr [:upper:] [:lower:]) is not etcd node, skipping etcd service installation.
  exit 0
fi

cd binaries
cp etcd etcdctl /usr/local/bin/
chmod +x /usr/local/bin/etcd*

pushd ../generated-files > /dev/null

# Set up etcd
mkdir -p /etc/etcd /var/lib/etcd
cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
cp etcd-$(hostname | tr [:upper:] [:lower:]).service /etc/systemd/system/etcd.service
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
sleep 5
#ETCDCTL_API=3 etcdctl --no-sync member list
ETCDCTL_API=3 etcdctl member list

popd > /dev/null
