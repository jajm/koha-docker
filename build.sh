#!/bin/sh

set -ex

find_version() {
    grep --max-count=1 --only-matching "$1\.[0-9][0-9]" "$1/Dockerfile"
}

for v in 19.11 20.05 20.11 21.05 21.11; do
    docker build --tag julianmaurice/koha:$(find_version $v) --tag julianmaurice/koha:$v $v
done
docker tag julianmaurice/koha:21.11 julianmaurice/koha:latest

docker build --tag julianmaurice/koha:master master

# Tag the intermediate image so it doesn't get removed by `docker image prune`
docker build --target builder --tag koha:master-slim-builder master-slim
docker build --tag julianmaurice/koha:master-slim master-slim

# List dangling images with `docker images -f dangling=true`
# Remove them with `docker image prune`
