#!/bin/bash
echo "Disabling firewalld..."
systemctl stop firewalld
systemctl disable firewalld
#Disable SELinux
var=$(sed -n -e 's/^SELINUX=\(.*\)$/\1/p' /etc/selinux/config)
if [ "$var" != "disabled" ]
then
    echo "Disabling SELinux..."
    sed -i.bak "s/^SELINUX=.*$/SELINUX=disabled/g" /etc/selinux/config
  echo -e "WARNING:  A reboot is now required, after rebooting you will need to rerun the install-kubernetes.sh script.  Press any key to reboot now..."
  read anykey
    reboot
else
    echo "SUCCESS:  SELinux is disabled.  Continuing to next step..."
fi
# Install dependencies
pushd binaries > /dev/null
yum -y install socat-1.7.3.2-2.el7.x86_64.rpm conntrack-tools-1.4.4-3.el7_3.x86_64.rpm ipset-6.29-1.el7.x86_64.rpm
popd > /dev/null
# Update /etc/hosts file
source ./settings.sh
#k8s will convert all hostname to lowercase,make sure we map lower case names in /etc/hosts file
for index in ${!WORKER_IP_LIST[@]}; do
  WORKER_HOSTNAME=${WORKER_HOSTNAME_LIST[index]}
  WORKER_IP=${WORKER_IP_LIST[index]}
  addToHosts ${WORKER_IP} ${WORKER_HOSTNAME}
done
for index in ${!CONTROLLER_IP_LIST[@]}; do
  CONTROLLER_HOSTNAME=${CONTROLLER_HOSTNAME_LIST[index]}
  CONTROLLER_IP=${CONTROLLER_IP_LIST[index]}
  addToHosts ${CONTROLLER_IP} ${CONTROLLER_HOSTNAME}
done
for index in ${!ETCD_IP_LIST[@]}; do
  ETCD_HOSTNAME=${ETCD_HOSTNAME_LIST[index]}
  ETCD_IP=${ETCD_IP_LIST[index]}
  addToHosts ${ETCD_IP} ${ETCD_HOSTNAME}
done
