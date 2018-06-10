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
# Only skip when it's a pure etcd
if isEtcd && ! isWorker && ! isController  ; then
  echo $(hostname | tr [:upper:] [:lower:]) is not controller or worker node, skipping flanneld installation.
  exit 0
fi
# Prepare keys required by flanneld
pushd generated-files > /dev/null
mkdir -p /var/lib/kubernetes
cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/
popd > /dev/null

# Need to call etcdctl later
pushd binaries > /dev/null
chmod +x etcdctl
popd > /dev/null

#Checking if flannel is running...
flanneldStatus=$(systemctl status -l flanneld | sed -n -e 's/.*Active:\s*\([a-z]*\).*/\1/p')
if [ "$flanneldStatus" != "active" ]; then
	#Install flanneld
	echo "Installing flanneld..."
	yum -y install binaries/flannel-0.5.5-8.fc25.x86_64.rpm

	#Configure flanneld
	echo "Configuring flanneld..."
	cp services/flanneld /etc/sysconfig/flanneld

  iface=`getNetworkInterface`
  if [ -z "$iface" ]; then
	  matchedIfaces=`ip link show | grep -v flannel | grep -E "eno|eth1" | wc -l`
	  if [ "1" == "$matchedIfaces" ]; then
    	iface=`ip link show | grep -v flannel | grep -E "eno|eth1" | cut -d: -f2 | xargs echo`
	  fi
	  echo -e "\nip -br a"
	  ip -br a
    echo -e "\n\nEnter the correct interface for flanneld based on the above command (eg. eth1):"
	  if [ -z "$iface" ]; then
	    echo -e "Failed to detect network interface for flanneld, please enter your manually."
	    read -p "Enter the network interface for flanneld:" iface
	  else
	    read -t 5 -p "$iface is detected for your flanneld network interface. Press Enter within 5 seconds to input your own..." ifinput
	    if [ "$?" = "0" ]; then
	      read -p "Enter the network interface for flanneld:" iface
	    fi
	  fi
  fi
  echo Using network interface $iface for flanneld...

	cp services/flanneld.service /usr/lib/systemd/system/flanneld.service
	sed -i.bak "s/FLANNEL_OPTIONS=\"--iface=ens192/FLANNEL_OPTIONS=\"--iface=$iface/g" /etc/sysconfig/flanneld
  sed -i.bak "s~\${ETCD_SERVER_IP}~$ETCD_SERVER_IP~g" /etc/sysconfig/flanneld

	if [ "$node" != "master" ]; then
		binaries/etcdctl --endpoints https://${ETCD_SERVER_IP}:2379 --ca-file generated-files/ca.pem --cert-file generated-files/kubernetes.pem --key-file generated-files/kubernetes-key.pem set /atomic.io/network/config '{ "Network": "10.1.0.0/16" }'
	else
		COUNTER=10
		echo "Getting flannel network config from etcdctl..."
		flannelConfig=$(binaries/etcdctl --endpoints https://${ETCD_SERVER_IP}:2379 --ca-file generated-files/ca.pem --cert-file generated-files/kubernetes.pem --key-file generated-files/kubernetes-key.pem --endpoint https://${ETCD_SERVER_IP}:2379 get /atomic.io/network/config)
		until [  $COUNTER -lt 1 ] || [ "$flannelConfig" != "" ]; do
		  echo COUNTER $COUNTER
		  let COUNTER-=1
		  sleep 5
		  flannelConfig=$(binaries/etcdctl --endpoints https://${ETCD_SERVER_IP}:2379 --ca-file generated-files/ca.pem --cert-file generated-files/kubernetes.pem --key-file generated-files/kubernetes-key.pem --endpoint https://${ETCD_SERVER_IP}:2379 get /atomic.io/network/config)
		done
		if [ "$flannelConfig" == "" ]; then
		  echo "ERROR:  Exiting because /atomic.io/network/config was not read from etcdctl..."
		  exit 1
		fi
		echo "Read etcdctl get /atomic.io/network/config as '$flannelConfig'"
	fi

	#Start flanneld...
	echo "Starting flanneld..."
	systemctl daemon-reload
	systemctl start flanneld
	systemctl enable flanneld
	flanneldStatus=$(systemctl status -l flanneld | sed -n -e 's/.*Active:\s*\([a-z]*\).*/\1/p')
	echo "flanneld has a status of '$flanneldStatus'"
	if [ "$flanneldStatus" != "active" ]; then
	  echo "ERROR:  Exiting because there is an issue with flanneld service state '$flanneldStatus' should be 'active'..."
	  exit 1
	fi
fi

subnets=$(binaries/etcdctl --endpoints https://${ETCD_SERVER_IP}:2379 --ca-file generated-files/ca.pem --cert-file generated-files/kubernetes.pem --key-file generated-files/kubernetes-key.pem --endpoint https://${ETCD_SERVER_IP}:2379 ls /atomic.io/network/subnets)
if [ "$subnets" == "" ]; then
  echo "ERROR:  There is a configuration error with flanneld.  One or more subnets should be found with the command 'binaries/etcdctl ls /atomic.io/network/subnets'..."
  exit 1
fi
