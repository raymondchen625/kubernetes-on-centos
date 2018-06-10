#!/bin/bash
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
source ./settings.sh
mkdir generated-files
pushd generated-files > /dev/null


# CA certs
generateFromTemplate ../templates/ca-config.json ca-config.json

generateFromTemplate ../templates/ca-csr.json ca-csr.json

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Gen admin client certs

generateFromTemplate ../templates/admin-csr.json admin-csr.json

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=${CERT_PROFILE} \
  admin-csr.json | cfssljson -bare admin

# Generate worker certs
for index in ${!WORKER_IP_LIST[@]}; do
  WORKER_HOSTNAME=${WORKER_HOSTNAME_LIST[index]}
  WORKER_IP=${WORKER_IP_LIST[index]}
  generateFromTemplate ../templates/kubelet-csr.json worker-${WORKER_HOSTNAME}-csr.json
  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname=${WORKER_HOSTNAME},${WORKER_IP} \
    -profile=${CERT_PROFILE} \
    worker-${WORKER_HOSTNAME}-csr.json | cfssljson -bare worker-${WORKER_HOSTNAME}
done

# Generate kube-proxy client certs
generateFromTemplate ../templates/kube-proxy-csr.json kube-proxy-csr.json

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=${CERT_PROFILE} \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

# Generate api-server certs used by etcd
generateFromTemplate ../templates/kube-apiserver-csr.json kubernetes-csr.json

read -r -a API_SERVER_CLIENTS <<< `removeDuplicate ${CONTROLLER_IP_LIST[@]} ${ETCD_IP_LIST[@]} ${API_SERVER_IP} ${ETCD_SERVER_IP}`
API_SERVER_CLIENT_IPS=`joinBy , "${API_SERVER_CLIENTS[@]}"`
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.32.0.10,${API_SERVER_CLIENT_IPS},127.0.0.1,kubernetes.default \
  -profile=${CERT_PROFILE} \
  kubernetes-csr.json | cfssljson -bare kubernetes
# 10.32.0.1 and 10.32.0.10 are IPs of cluster DNS server(skydns and kube-dns)
popd > /dev/null
