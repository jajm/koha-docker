#!/bin/sh

URL='https://github.com/Koha-Community/Koha'

compare() {
    latest=$(git ls-remote --refs --sort=-version:refname $URL $1 | head -n 1 | awk '{print $2}' | sed 's,refs/tags/,,')
    if [ "$latest" = "$2" ]; then
        echo "$latest OK ($(get_tag_date "$latest"))"
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

get_tag_date() {
    tag_url=$(curl -sSL "https://api.github.com/repos/Koha-Community/Koha/git/ref/tags/$1" | jq -r '.object.url')
    tag_date=$(curl -sSL "$tag_url" | jq -r '.tagger.date')
    date -d "$tag_date" +%F
}

for v in 19.11 20.05 20.11 21.05 21.11; do
    check_version $v
done
