#!/bin/bash

set -e

cd /tmp

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}.deb
sha1sum elasticsearch-${ELASTIC_VERSION}.deb
sudo dpkg -i elasticsearch-${ELASTIC_VERSION}.deb

wget https://artifacts.elastic.co/downloads/kibana/kibana-5.1.1-amd64.deb
sha1sum kibana-5.1.1-amd64.deb
sudo dpkg -i kibana-5.1.1-amd64.deb
