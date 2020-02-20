#!/bin/sh

set -ex

docker build --tag julianmaurice/koha:18.11.13 --tag julianmaurice/koha:18.11 18.11
docker build --tag julianmaurice/koha:19.05.07 --tag julianmaurice/koha:19.05 19.05
docker build --tag julianmaurice/koha:19.11.02 --tag julianmaurice/koha:19.11 --tag julianmaurice/koha:latest 19.11
docker build --tag julianmaurice/koha:master master

# Tag the intermediate image so it doesn't get removed by `docker image prune`
docker build --target builder --tag koha:master-slim-builder master-slim
docker build --tag julianmaurice/koha:master-slim master-slim

# List dangling images with `docker images -f dangling=true`
# Remove them with `docker image prune`
