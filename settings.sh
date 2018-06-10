#!/bin/bash
# Settings of the Kubernetes cluster

# Hostname and IP settings
# API_SERVER_IP should be the IP of the loadbalancer for the API Servers.
# When there is no loadbalancer for API Servers, set to the first master's IP for simplicity.
API_SERVER_IP=192.168.1.28
# ETCD_SERVER_IP should be the IP of the loadbalancer for the ETCD nodes.
# Where there is no loadbalancer for ETCD, set to the first etcd's IP for simplicity.
ETCD_SERVER_IP=192.168.1.28
# IPs and Hostnames settings for all nodes (etcd, master and worker)
# Use comma(,) to separate multiple values, IP and Hostname must show up in pair and in the same order
ETCD_IPS="192.168.1.28"
ETCD_HOSTNAMES="k8svm"
MASTER_IPS="192.168.1.28"
MASTER_HOSTNAMES="k8svm"
WORKER_IPS="192.168.1.28"
WORKER_HOSTNAMES="k8svm"

# --- Settings below are usually not required to change ---
# Certificate settings
CERT_CN=Kubernetes
CERT_C=US
CERT_L=Portland
CERT_ST=Oregon
CERT_OU=CA
CERT_PROFILE=kubernetes
# Misc settings
CLUSTER_NAME=kubernetes
POD_CIDR="172.16.11.0/24"


# Settings end here

# --- Below are functions which are not customizable ---
IFS="," read -r -a ETCD_IP_LIST <<< "${ETCD_IPS}"
IFS="," read -r -a ETCD_HOSTNAME_LIST <<< "${ETCD_HOSTNAMES}"
IFS="," read -r -a CONTROLLER_IP_LIST <<< "${MASTER_IPS}"
IFS="," read -r -a CONTROLLER_HOSTNAME_LIST <<< "${MASTER_HOSTNAMES}"
IFS="," read -r -a WORKER_IP_LIST <<< "${WORKER_IPS}"
IFS="," read -r -a WORKER_HOSTNAME_LIST <<< "${WORKER_HOSTNAMES}"
unset IFS
# Convert all hostnames to lowercase
read -r -a WORKER_HOSTNAME_LIST <<< "`echo ${WORKER_HOSTNAME_LIST[*]} | tr [:upper:] [:lower:]`"
read -r -a CONTROLLER_HOSTNAME_LIST <<< "`echo ${CONTROLLER_HOSTNAME_LIST[*]} | tr [:upper:] [:lower:]`"
read -r -a ETCD_HOSTNAME_LIST <<< "`echo ${ETCD_HOSTNAME_LIST[*]} | tr [:upper:] [:lower:]`"
# Function to join an array($2) by specified separator($1)
function joinBy { local IFS="$1"; shift; echo "$*"; }

function generateFromTemplate()
{
  templateFile=$1
  destFile=$2
  if [ -z "$templateFile"  -o -z "destFile" ]; then
    echo "Need two parameters: templateFile and destFile"
    exit 1
  fi
  cp -f $templateFile $destFile
	#replace all variable values defined above
  sed -i "s~\${API_SERVER_IP}~$API_SERVER_IP~g" $destFile
  sed -i "s~\${ETCD_SERVER_IP}~$ETCD_SERVER_IP~g" $destFile
	sed -i "s~\${CERT_CN}~$CERT_CN~g" $destFile
  sed -i "s~\${CERT_C}~$CERT_C~g" $destFile
  sed -i "s~\${CERT_L}~$CERT_L~g" $destFile
  sed -i "s~\${CERT_ST}~$CERT_ST~g" $destFile
  sed -i "s~\${CERT_OU}~$CERT_OU~g" $destFile
  sed -i "s~\${CERT_PROFILE}~$CERT_PROFILE~g" $destFile
  sed -i "s~\${CLUSTER_NAME}~$CLUSTER_NAME~g" $destFile
  sed -i "s~\${CLUSTER_NAME}~$CLUSTER_NAME~g" $destFile
  sed -i "s~\${POD_CIDR}~$POD_CIDR~g" $destFile
  #replace variables defined in the scripts
  sed -i "s~\${WORKER_HOSTNAME}~$WORKER_HOSTNAME~g" $destFile
  sed -i "s~\${ENCRYPTION_KEY}~$ENCRYPTION_KEY~g" $destFile
  sed -i "s~\${INTERNAL_IP}~$INTERNAL_IP~g" $destFile
  sed -i "s~\${INITIAL_CLUSTER}~$INITIAL_CLUSTER~g" $destFile
  sed -i "s~\${ETCD_NAME}~$ETCD_NAME~g" $destFile
  sed -i "s~\${ETCD_NAME}~$ETCD_NAME~g" $destFile
  sed -i "s~\${ETCD_SERVERS}~$ETCD_SERVERS~g" $destFile
}


function isEtcd()
{
  if isHostInList ${ETCD_HOSTNAME_LIST[*]}; then return 0; else return 1; fi
}

function isController()
{
  if isHostInList ${CONTROLLER_HOSTNAME_LIST[*]}; then return 0; else return 1; fi
}

function isWorker()
{
  if isHostInList ${WORKER_HOSTNAME_LIST[*]}; then return 0; else return 1; fi
}

function isHostInList() {
  hostname="$(hostname | tr [:upper:] [:lower:])"
  read -r -a hlist <<< "$*"
  for h in ${hlist[*]} ; do
    if [ "$h" = "$hostname" ]; then
      return 0
    fi
  done
  return 1
}

function getNetworkInterface() {
  hostname="$(hostname | tr [:upper:] [:lower:])"
  for index in ${!WORKER_HOSTNAME_LIST[@]}; do
    if [ "${WORKER_HOSTNAME_LIST[index]}" = "$hostname" ]; then
      ipAddress=${WORKER_IP_LIST[index]}
      netIntf=`ifconfig | grep $ipAddress -B1 | head -1 | cut -d: -f1`
      if [ -z $netIntf ]; then
        return 1
      else
        echo $netIntf
        return 0
      fi
    fi
  done
  return 1
}

# The function to add an etnry to /etc/hosts file, skip if it already exists
# parameter: ipAddress hostname
function addToHosts() {
  if [ -z "$1" -o -z "42" ]; then
    echo "Must provide \"IPAddress Hostname\" as parameters."
    return 1
  fi
  entry="$1 $2"
  if grep -q "${entry}" /etc/hosts ; then
    echo "Already exists in /etc/hosts : $entry"
  else
    echo $entry >> /etc/hosts
  fi
}
function deleteFromHosts() {
  if [ -z "$1" -o -z "42" ]; then
    echo "Must provide \"IPAddress Hostname\" as parameters."
    return 1
  fi
  entry="$1 $2"
  if grep -q "${entry}" /etc/hosts ; then
    sed -i "/${entry}/d" /etc/hosts
  else
    echo "Skipped deleting non-existing entry in /etc/hosts : $entry"
  fi
}

# Get a string separated by space, remove the duplicate entries and return a new string
function removeDuplicate() {
  read -r -a list <<< "$*"
  uniqueList=($(echo "${list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  echo ${uniqueList[@]}
}
