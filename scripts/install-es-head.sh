#!/bin/bash

set -e

git clone git://github.com/mobz/elasticsearch-head.git
cd elasticsearch-head
sudo docker pull mobz/elasticsearch-head:5
