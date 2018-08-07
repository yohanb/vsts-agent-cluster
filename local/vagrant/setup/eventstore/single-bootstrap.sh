#!/bin/bash

curl -s https://packagecloud.io/install/repositories/EventStore/EventStore-OSS/script.deb.sh | sudo bash
sudo apt-get install eventstore-oss=4.0.3

cat >/etc/eventstore/eventstore.conf <<EOL
---
ClusterSize: 1
ExtIp: 0.0.0.0
RunProjections: All
EOL

sudo service eventstore start

