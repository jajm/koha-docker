#!/bin/sh

set -ex

docker build --tag julianmaurice/koha:18.11.13 --tag julianmaurice/koha:18.11 18.11
docker build --tag julianmaurice/koha:19.05.07 --tag julianmaurice/koha:19.05 19.05
docker build --tag julianmaurice/koha:19.11.02 --tag julianmaurice/koha:19.11 --tag julianmaurice/koha:latest 19.11
docker build --tag julianmaurice/koha:master --build-arg GIT_CLONE_TIMESTAMP=$(date +%s) master

# Remove dangling images by running `docker rmi $(docker images -f 'dangling=true' -q)`
