#!/bin/sh

while read ar; do
    [ -f "$ar" ] || { echo "not a file: $ar" >&2; exit 1; }
    readlink -f "$ar"
done |
while read archive; do
    dir="$(mktemp -d /dev/shm/fi.XXXXXXXX)"
    version="$(basename $archive | sed 's/\.tar\.gz$//')"
    mod="$(stat -c %Y $archive) +0200"
    now="$(date +%s) +0200"
    msg="import $version"

    cd "$dir" &&
    tar xfz "$archive" &&
    echo "commit refs/heads/master" &&
    echo "author Bram Moolenaar <bram@vim.org> $mod" &&
    echo "committer Julius Plenz <julius@plenz.com> $now" &&
    echo -n "data " && echo -n "$msg" | wc -c && echo "$msg" &&
    echo "deleteall" &&
    find . -type f |
    while read f; do
        echo -n "M 644 inline "
        echo "$f" | sed -e 's,^\./[^/]*/,,'
        echo -n "data " && wc -c < "$f" && cat "$f"
    done &&
    echo
    rm -fr "$dir"
done
