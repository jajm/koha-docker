#!/bin/sh

URL='https://github.com/Koha-Community/Koha'

compare() {
    latest=$(git ls-remote --refs --sort=-version:refname $URL $1 | head -n 1 | awk '{print $2}' | sed 's,refs/tags/,,')
    if [ "$latest" = "$2" ]; then
        echo "$latest OK"
    else
        echo "New version: $latest (old: $2)"
    fi
}

find_version() {
    grep --max-count=1 --only-matching "v$1\.[0-9][0-9]" "$1/Dockerfile"
}

check_version() {
    compare "v$1.*" $(find_version $1)
}

for v in 19.11 20.05 20.11; do
    check_version $v
done
