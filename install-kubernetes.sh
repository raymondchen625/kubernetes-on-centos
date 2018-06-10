#!/bin/bash
# Run all commands
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi

if [ ! -d binaries ]; then
  echo "Software packages are not downloaded yet. Please run ./download-binaries.sh to download."
  exit 1
fi

if [ ! -d generated-files ]; then
  echo "Certificates and configs are not generated. Please run ./generate-settings.sh to generate them and copy them to all nodes."
  exit 1
fi

for i in install-{0,1}*.sh; do
  echo Running $i
  ./$i
done
echo "Kubernetes setup work on $(hostname | tr [:upper:] [:lower:]) is done."
