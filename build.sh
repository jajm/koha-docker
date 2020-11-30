#!/bin/sh

set -ex

docker build --tag julianmaurice/koha:19.05.17 --tag julianmaurice/koha:19.05 19.05
docker build --tag julianmaurice/koha:19.11.12 --tag julianmaurice/koha:19.11 19.11
docker build --tag julianmaurice/koha:20.05.06 --tag julianmaurice/koha:20.05 20.05
docker build --tag julianmaurice/koha:20.11.00 --tag julianmaurice/koha:20.11 --tag julianmaurice/koha:latest 20.11
docker build --tag julianmaurice/koha:master master
docker build --tag julianmaurice/koha:master-mojo master-mojo

# Tag the intermediate image so it doesn't get removed by `docker image prune`
docker build --target builder --tag koha:master-slim-builder master-slim
docker build --tag julianmaurice/koha:master-slim master-slim

# List dangling images with `docker images -f dangling=true`
# Remove them with `docker image prune`
