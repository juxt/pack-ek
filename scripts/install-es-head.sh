#!/bin/bash

set -e

git clone git://github.com/mobz/elasticsearch-head.git
cd elasticsearch-head
# sudo docker build .
sudo docker run -d -p 9100:9100 mobz/elasticsearch-head:5
