#!/bin/sh
set -euo pipefail

cd /tmp/output

repo_dir = /tmp/repo/

output=$(pvs-studio-arch-update)
if [ -n "$output" ]; then
    echo "$output"

    before=$(find . -type f)

    makepkg -c

    after=$(find . -type f)
    latest_pkg=$(comm -13 <(echo "$before") <(find . -type f) | grep '\.pkg\.tar\.zst$' | tail -n 1 || true)

    if [ -n "$latest_pkg" ]; then
        cp "$latest_pkg" "$repo_dir"
        echo "Пакет $latest_pkg скопирован в $repo_dir"

        cd "$repo_dir"
        repo-add custom.db.tar.gz *.pkg.tar.zst
    else
        echo "Новый пакет не найден."
    fi
fi
