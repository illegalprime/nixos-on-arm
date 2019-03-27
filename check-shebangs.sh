#!/usr/bin/env bash
set -euo pipefail

artifact="$1"
closure=$(nix path-info --json -r "$(readlink "${artifact}")")

mapfile -t derivations < <(jq -cr '.[]' <<< "$closure")

for derivation in "${derivations[@]}"; do
    path=$(jq -r '.path' <<< "$derivation")
    echo checking "$path"... >&2

    while IFS= read -r -d $'\0' f; do
        match=$(head -1 "$f" | grep -P '#!\s*/[^n]' || :)
        if [[ $match ]]; then
            echo "$f: $match"
        fi
    done < <(find "$path" -type f -perm -0100 -print0)
done
