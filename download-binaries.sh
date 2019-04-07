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
verifyBinary docker-ce-18.09.4-3.el7.x86_64.rpm a7b1a96fb1ba68a4f870bf9d7120c16e6078e267e82125156fb75529e341bc7b https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-18.09.4-3.el7.x86_64.rpm
verifyBinary docker-ce-cli-18.09.4-3.el7.x86_64.rpm 6069f7103dfc005ba100c2e3b1f873beeb79e1d89d3d0d0693742288b6a0e563 https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-18.09.4-3.el7.x86_64.rpm
verifyBinary docker-ce-selinux-17.03.3.ce-1.el7.noarch.rpm 50d75b9412e1a3056bfa8f0436114d1ff8c1073f916d1e9b8ba46bb49024ee86 https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.3.ce-1.el7.noarch.rpm
verifyBinary etcd-v3.3.12-linux-amd64.tar.gz dc5d82df095dae0a2970e4d870b6929590689dd707ae3d33e7b86da0f7f211b6 https://github.com/etcd-io/etcd/releases/download/v3.3.12/etcd-v3.3.12-linux-amd64.tar.gz
verifyBinary flannel-0.7.1-4.el7.x86_64.rpm c792ae099139b2cba21f0f2726032e6b02dec6f1248e3eed8fb87a206319126c http://rpmfind.net/linux/centos/7.6.1810/extras/x86_64/Packages/flannel-0.7.1-4.el7.x86_64.rpm
verifyBinary ipset-6.29-1.el7.x86_64.rpm 579fc11b5a113b69cf6721478c71d83104cdc894365318bd1fca2c9b577b9a04 https://rpmfind.net/linux/centos/7.5.1804/os/x86_64/Packages/ipset-6.29-1.el7.x86_64.rpm
verifyBinary kube-apiserver 6a27afb355a9dda9dddcdbe3c2d031a5c843036cdc2f453841992c111978e008 https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kube-apiserver
verifyBinary kube-controller-manager 00386973f990bfd90fbd944a02111d0b92179ed7612414e1aa7f836dd177659e https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kube-controller-manager
verifyBinary kube-proxy 21fa27ad16f56b28fa6d57a8be84174fd93daf6ccf90a1f40e3924df0fe69468 https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kube-proxy
verifyBinary kube-scheduler 860f3bfbf81c7e5834fc6db1806a54c0b44ab66d6d0e89572b07234e346e7b8d https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kube-scheduler
verifyBinary kubectl 99ade995156c1f2fcb01c587fd91be7aae9009c4a986f43438e007265ca112e8 https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
verifyBinary kubelet bcd3ae191947e55de6ee9f47ff9f68a711149d20b46ca4342aac367ded4ffc85 https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubelet
verifyBinary socat-1.7.3.2-2.el7.x86_64.rpm 4430a4013892bc2c51d79358b16032e95269d7bc66c604cbdee89a1559c1c617 https://rpmfind.net/linux/centos/7.5.1804/os/x86_64/Packages/socat-1.7.3.2-2.el7.x86_64.rpm
popd > /dev/null > /dev/null
