#!/bin/bash
# Run all commands
if [[ ! "$PATH" =~ "/usr/local/bin" ]]; then
   echo "/usr/local/bin is not on your PATH. Please add it:"
   echo "export PATH=\$PATH:/usr/local/bin"
   exit 1
fi
if [ -d generated-files ]; then
  echo "Certificates and configs already exist. Continue to delete them and regenerete new ones?(y/n)"
  read answer
  if [ ! "y" = "$answer" ]; then
    echo "Aborted."
    exit 0
  fi
fi
for i in prepare-0*.sh; do
  echo Running $i
  ./$i
done
echo "Kubernetes certificates and settings generated in generated-file folder!"
