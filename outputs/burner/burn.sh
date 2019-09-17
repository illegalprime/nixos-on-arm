#!/usr/bin/env bash
set -euxo pipefail

read -r -a LEDS <<< "$leds"

function leds_working() {
    # set all LEDs to user-controllable
    for led in "${LEDS[@]}"; do
        echo none > "/sys/class/leds/${led}/trigger"
    done

    # build the pattern
    local pattern=()
    for i in "${!LEDS[@]}"; do
        pattern[$i]="${LEDS[$i]}"
        pattern[$((${#LEDS[@]} * 2 - i))]="${LEDS[$i]}"
    done
    pattern[$((${#LEDS[@]}))]=off
    pattern[$((${#LEDS[@]} * 2 + 1))]=off

    # run the pattern forever
    while :; do
        for led in "${pattern[@]}"; do
            for dark in "${LEDS[@]}"; do
                if [[ "$led" == "$dark" ]]; then
                    echo 255 > "/sys/class/leds/${dark}/brightness"
                else
                    echo 0 > "/sys/class/leds/${dark}/brightness"
                fi
            done
            sleep 0.1
        done
    done
}

function leds_done() {
    for led in "${LEDS[@]}"; do
        echo none > "/sys/class/leds/${led}/trigger"
        echo 255 > "/sys/class/leds/${led}/brightness"
    done
}

function leds_error() {
    # set all LEDs to user-controllable
    for led in "${LEDS[@]}"; do
        echo none > "/sys/class/leds/${led}/trigger"
    done

    # run the pattern forever
    local level=255
    while :; do
        for led in "${LEDS[@]}"; do
            echo "$level" > "/sys/class/leds/${led}/brightness"
        done
        if [[ $level == 255 ]]; then
            level=0
        else
            level=255
        fi
        sleep 0.5
    done
}

# set -x on the pulsing lights is log spam
( set +x; leds_working ) &

# do the actual work
bmaptool copy --bmap "$bmap" "$payload" "$disk" || RET=$?

kill %1 # kill the indicator lights

if [[ ${RET:-0} == 0 ]]; then
    leds_done
else
    leds_error
fi
