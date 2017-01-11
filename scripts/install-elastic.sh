#!/bin/bash

set -e

cd /tmp
curl -L -o elastic.rpm https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/${ELASTIC_VERSION}/elasticsearch-${ELASTIC_VERSION}.rpm
sudo rpm -Uvh elastic.rpm
rm elastic.rpm

cd /usr/share/elasticsearch
sudo chown elasticsearch:elasticsearch -R .
