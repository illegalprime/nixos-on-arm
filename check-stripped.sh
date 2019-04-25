#!/usr/bin/env bash
set -euo pipefail

artifact="$1"
closure=$(nix path-info --json -r "$(readlink "${artifact}")")

mapfile -t derivations < <(jq -cr '.[]' <<< "$closure")

for derivation in "${derivations[@]}"; do
    path=$(jq -r '.path' <<< "$derivation")
    drv=$(jq -r '.deriver' <<< "$derivation")
    file_types=$(find "$path" -type f -exec file -b {} +)
    if grep 'not stripped' <<< "$file_types" &>/dev/null; then
        echo "$path -> not stripped"
        drv=$(nix show-derivation "$drv")
        dontStrip=$(jq -r '.[] | .env.dontStrip | select(.)' <<< "$drv")
        sepDebug=$(jq -r '.[] | .env.separateDebugInfo | select(.)' <<< "$drv")
        if [[ $dontStrip ]]; then
            echo "    dontStrip = $dontStrip"
        fi
        if [[ $sepDebug ]]; then
            echo "    separateDebugInfo = $sepDebug"
        fi
    fi
done
