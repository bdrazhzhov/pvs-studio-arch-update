#!/bin/sh
set -euo pipefail

cd /tmp/output

output=$(pvs-studio-arch-update)
if [ -n "$output" ]; then
    echo "$output"

    before=$(find . -type f)

    makepkg -c

    after=$(find . -type f)
    latest_pkg=$(comm -13 <(echo "$before") <(find . -type f) | grep '\.pkg\.tar\.gz$' | tail -n 1 || true)

    if [ -n "$latest_pkg" ]; then
        cp "$latest_pkg" /tmp/repo/
        echo "Пакет $latest_pkg скопирован в /tmp/repo/"
    else
        echo "Новый пакет не найден."
    fi
fi
