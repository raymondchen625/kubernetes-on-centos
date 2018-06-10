#!/bin/bash

# Remove all containers that are exited or dead
docker rm $(docker ps -a -f status=exited -f status=dead -q)

# Get a list of all images with their tags, and remove them all.  This will fail when trying to remove images that are being used by existing containers
# Adapted from eduardocardoso's code (https://gist.github.com/eduardocardoso/82a629882ddb02ab3677)
# $1 is "REPOSITORY" column. $2 is "TAG" column
docker rmi $(docker images | tail -n +2 | awk '{ img_id=$1; if($2!="<none>")img_id=img_id":"$2; print img_id}')

# Get a list of images without a name or tag, and try to remove them all.
# This will fail when trying to remove images that are being used by
# existing containers.
docker rmi $(docker images | grep "<none>" | awk '{print $3}')

# Remove all dangling images
docker rmi $(docker images -q --filter "dangling=true")

# clean up volume
docker volume ls -qf dangling=true | xargs -r docker volume rm

cd /tmp ; find . -iname "kube*`hostname`*" -mtime +2 -print | xargs rm -f
cd /etc/systemd/system/multi-user.target.wants; for i in `ls kube*`; do systemctl stop $i; systemctl start $i; done
