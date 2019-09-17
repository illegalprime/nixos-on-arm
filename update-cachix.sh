#!/usr/bin/env bash
set -euo pipefail

function build_n_push() {
    local machine="$1"
    local image="$2"

    nix-build . \
              --no-build-output \
              -I nixpkgs=nixpkgs \
              -I machine="$machine" \
              -I image="$image"

    if [[ ${CACHIX_AUTH_TOKEN:-} ]]; then
        cachix push cross-armed $(readlink -f result)
        cachix push cross-armed $(nix-store -qd result)
    fi
}

build_n_push machines/raspberrypi-zerow images/mini
build_n_push machines/raspberrypi-zero  images/mini
build_n_push machines/raspberrypi-2     images/mini
build_n_push machines/raspberrypi-3     images/mini
build_n_push machines/beaglebone        images/mini
build_n_push machines/odroid-c2         images/mini

