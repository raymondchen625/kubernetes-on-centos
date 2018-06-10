#!/bin/bash
echo "Deploy cron.daily job for logs and images cleanup..."
# Set up cron job for logs and images cleanup
cp services/k8s-cleanup.sh /etc/cron.daily/k8s-cleanup.sh
chmod +x /etc/cron.daily/k8s-cleanup.sh
