### Kubernetes setup script

# Host OS:
  CentOS 7 or RedHat EL 7.4+
# Components:
  * etcd: 3.2.11
  * flannel: 0.5.5
  * kubernetes: 1.9.8
  * docker: 17.3.2

# Features:
  TLS/SSL enabled with self-signed certificates
  Restriction on access to API Server (kubeconfig with certificates and keys is required) (This is turned off for easy access to dashboard. Can be turned on manually)

# Usage
* Configure settings.sh, main items:
  1. ETCD_SERVER_IP: etcd loadbalancer IP or one of the IPs in ETCD_IPS
  2. API_SERVER_IP: API server IP or one of the IPs in MASTER_IPS
  3. IP & hostname list of etcd, master and worker
  3 components can run on the same node or separately, depending on which list the node is in. Single node is a special case when all 3 set of lists contain exact the same IP and hostname.
* After configuration of settings.sh, run:
  1. ./download-binaries.sh #This only needs to run once. We can keep the downloaded files in folder 'binaries'  
  2. ./generate-settings.sh #This generates the certs and all the setting files
  3. copy the whole script directory to all nodes, including changed settings.sh, other scripts, binaries and generated files under 'generated-files' folder
  4. Run ./install-kubernetes.sh on all nodes in the order of etcd -> master -> worker
* Uninstall: run ./uninstall.sh on all nodes in the order of master -> worker -> etcd
