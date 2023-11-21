#!/bin/sh

set -ex

find_version() {
    grep --max-count=1 --only-matching "$1\.[0-9][0-9]" "$1/Dockerfile"
}

for v in 21.11 22.05 22.11 23.05; do
    podman build --tag ghcr.io/jajm/koha:"$(find_version $v)" --tag ghcr.io/jajm/koha:"$v" "$v"
done
podman tag ghcr.io/jajm/koha:23.05 ghcr.io/jajm/koha:latest

podman build --tag ghcr.io/jajm/koha:master master

# Tag the intermediate image so it doesn't get removed by `podman image prune`
podman build --target builder --tag koha:master-slim-builder master-slim
podman build --tag ghcr.io/jajm/koha:master-slim master-slim

# List dangling images with `podman images -f dangling=true`
# Remove them with `podman image prune`
