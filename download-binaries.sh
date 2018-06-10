#!/bin/bash
function verifyBinary() {
  filename=$1
  sha256Hash=$2
  url=$3
  echo -e "Verifying $filename with sha256: $sha256Hash"
  if [ -f $filename ]; then
    hash=`openssl sha -sha256 $filename | awk '{print $2}'`
    if [ $hash = $sha256Hash ]; then
      return 0
    else
      echo "Incorrect hash value $hash for $filename, expecting $sha256Hash"
      return 1
    fi
  fi
  echo "Downloading file $filename ..."
  if [[ $url =~ "tar.gz" ]]; then
    tarBall=${url##*/}
    echo tarBall = $tarBall
    curl -L $url -o $tarBall
    folder=${tarBall%.tar.gz}
    tar zxvf $tarBall
    cp ${folder}/etcd ${folder}/etcdctl .
  else
    curl -L $url -o $filename
  fi
  if [ -f $filename ]; then
    verifyBinary $filename $sha256Hash
  else
    echo "failed to download $filename from $url"
    return 1
  fi
  return 0
}
mkdir -p binaries
pushd binaries >> /dev/null

verifyBinary cfssl_linux-amd64 eb34ab2179e0b67c29fd55f52422a94fe751527b06a403a79325fed7cf0145bd https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
verifyBinary cfssljson_linux-amd64 1c9e628c3b86c3f2f8af56415d474c9ed4c8f9246630bd21c3418dbe5bf6401e https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
verifyBinary conntrack-tools-1.4.4-3.el7_3.x86_64.rpm 2a2ca9f95b1506f519b2fd19891d4970529ebedc44e5203dd1cf46f9b4f3b7ba https://rpmfind.net/linux/centos/7.5.1804/os/x86_64/Packages/conntrack-tools-1.4.4-3.el7_3.x86_64.rpm
verifyBinary docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm 0ead9d0db5c15e3123d3194f71f716a1d6e2a70c984b12a5dde4a72e6e483aca https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm
verifyBinary docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm 07e6cbaf0133468769f5bc7b8b14b2ef72b812ce62948be0989a2ea28463e4df https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
verifyBinary etcd a56818292bcdc38b298e03f73a9101628438e5d99bb08155db063a8f557bd2cb https://github.com/coreos/etcd/releases/download/v3.2.11/etcd-v3.2.11-linux-amd64.tar.gz
verifyBinary etcdctl 3a5ee5a41c813938d2dfea70c18f4f09e214a5460c37a4ab96e49b1db6b0f724 https://github.com/coreos/etcd/releases/download/v3.2.11/etcd-v3.2.11-linux-amd64.tar.gz
verifyBinary flannel-0.5.5-8.fc25.x86_64.rpm 77b0934194d0103ca0cdc376df1998c6758388f17636d882909d40250fd84918 https://rpmfind.net/linux/fedora/linux/releases/25/Everything/x86_64/os/Packages/f/flannel-0.5.5-8.fc25.x86_64.rpm
verifyBinary ipset-6.29-1.el7.x86_64.rpm 579fc11b5a113b69cf6721478c71d83104cdc894365318bd1fca2c9b577b9a04 https://rpmfind.net/linux/centos/7.5.1804/os/x86_64/Packages/ipset-6.29-1.el7.x86_64.rpm
verifyBinary kube-apiserver 94b8750e68c53eea448a756e2369c4d1a0e2ccfb58129bdbd011f05592d07af2 https://storage.googleapis.com/kubernetes-release/release/v1.9.8/bin/linux/amd64/kube-apiserver
verifyBinary kube-controller-manager 1218d4b63735f184ef8f6e66ec46cd438b0578d3bf64aa0e599f17ffb3abd1e3 https://storage.googleapis.com/kubernetes-release/release/v1.9.8/bin/linux/amd64/kube-controller-manager
verifyBinary kube-proxy cdccb8e04bc43922402553c36e60b841bf74464892b1e1278723b73da4ada376 https://storage.googleapis.com/kubernetes-release/release/v1.9.8/bin/linux/amd64/kube-proxy
verifyBinary kube-scheduler c1cab313eaeeee1562161b06d941efbba3633f3261ceb45b86018f843e3dccbf https://storage.googleapis.com/kubernetes-release/release/v1.9.8/bin/linux/amd64/kube-scheduler
verifyBinary kubectl dd7cdde8b7bc4ae74a44bf90f3f0f6e27206787b27a84df62d8421db24f36acd https://storage.googleapis.com/kubernetes-release/release/v1.9.8/bin/linux/amd64/kubectl
verifyBinary kubelet afc840d987ae791e245556c36b443281db65f893cd920f6f9dfbf1ef75211881 https://storage.googleapis.com/kubernetes-release/release/v1.9.8/bin/linux/amd64/kubelet
verifyBinary socat-1.7.3.2-2.el7.x86_64.rpm 4430a4013892bc2c51d79358b16032e95269d7bc66c604cbdee89a1559c1c617 https://rpmfind.net/linux/centos/7.5.1804/os/x86_64/Packages/socat-1.7.3.2-2.el7.x86_64.rpm
popd > /dev/null > /dev/null
