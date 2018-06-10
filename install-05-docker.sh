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

# make sure ip_forward is enabled so Docker won't apply drop-forward rule in iptables
cat /etc/sysctl.conf |grep 'net.ipv4.ip_forward=1' > /dev/null
[[ "$?" == "0" ]] || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -w net.ipv4.ip_forward=1

dockerStatus=$(systemctl status -l docker | sed -n -e 's/.*Active:\s*\([a-z]*\).*/\1/p')
if [ "$dockerStatus" != "active" ]; then

	#If docker already exists on the machine, remove the contents of /etc/systemd/system/docker.service.d/
	rm -rf /etc/systemd/system/docker.service.d/*

	#Install docker
	echo "Installing docker..."
  pushd binaries > /dev/null
  yum -y erase docker-engine-selinux
	yum -y install docker-ce*.rpm
  popd > /dev/null

  cp services/docker.service /usr/lib/systemd/system/docker.service

 	#Start docker...
	echo "Starting docker..."
	systemctl daemon-reload
	systemctl start docker
	systemctl enable docker

	dockerStatus=$(systemctl status -l docker | sed -n -e 's/.*Active:\s*\([a-z]*\).*/\1/p')
	echo "docker has a status of '$dockerStatus'"
	if [ "$dockerStatus" != "active" ]; then
	  echo "ERROR:  Exiting because there is an issue with docker service state '$dockerStatus' should be 'active'..."
	  exit 1
	fi
fi
