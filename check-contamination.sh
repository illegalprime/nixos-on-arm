#!/usr/bin/env bash
set -euo pipefail

artifact="$1"
closure=$(nix path-info --json -r "$(readlink "${artifact}")")

mapfile -t derivations < <(jq -cr '.[]' <<< "$closure")
declare -A system

# mark x86 or not
for derivation in "${derivations[@]}"; do
    path=$(jq -r '.path' <<< "$derivation")
    echo -n checking "$path"... >&2
    if [[ "$path" =~ -unknown-linux-gnueabihf-binutils-wrapper- ]]; then
        system[${path}]='build'
        echo ' (assuming build)' >&2
    elif [[ "$path" =~ -dev$ ]]; then # dev outputs are meant for the build system
        system[${path}]='build'
        echo ' (assuming build)' >&2
    elif find "$path" -type f -exec file -b {} + | grep 'x86-64' >/dev/null; then
        system[${path}]='build'
        echo ' build' >&2
    else
        system[${path}]='host'
        echo ' host' >&2
    fi
done

# find host paths that have build run-time dependencies
for derivation in "${derivations[@]}"; do
    path=$(jq -r '.path' <<< "$derivation")
    path_system=${system[${path}]}
    mapfile -t references < <(jq -r '.references | .[]' <<< "$derivation")
    for reference in "${references[@]}"; do
        dep_system=${system[${reference}]}
        if [[ "$dep_system" = "build" && "$path_system" = "host" && "$path" != "$reference" ]]; then
            echo "$path -> $reference"
        fi
    done
done
