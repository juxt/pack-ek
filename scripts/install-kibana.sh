#!/bin/bash

set -e

cd /tmp

wget https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-amd64.deb
sha1sum kibana-${KIBANA_VERSION}-amd64.deb
sudo dpkg -i kibana-${KIBANA_VERSION}-amd64.deb
